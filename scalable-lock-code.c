#define CACHELINE 64
struct lock {
  // t-s and t-s-exp
  volatile unsigned int locked;

  // ticket
  volatile unsigned int next_ticket;
  volatile int now_serving;

  // anderson
  volatile struct {
    volatile int x;
    char cache_line[CACHELINE];
  } has_lock[100];
  volatile unsigned int queueLast;
  unsigned int holderPlace;
};

static inline unsigned int
TestAndSet(volatile unsigned int *addr)
{
  unsigned int result;
  unsigned int new = 1;
  
  // x86 atomic exchange.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
               "1" (new) :
               "cc");
  return result;
}


/*
 * Test-and-Set
 */
void
t_s_acquire(struct lock *lock)
{
  while(TestAndSet(&lock->locked) == 1)
    ;
}

void
t_s_release(struct lock *lock)
{
  lock->locked = 0;
}

/*
 * Test-and-Set with exponential delay
 * Simplified -- no randomness.
 */
void
t_s_exp_acquire(struct lock *lock)
{
  int delay = 1;
  int i, junk = 0;
  volatile int junkjunk;

  while(TestAndSet(&lock->locked) == 1){
    // delay
    int howlong = xrandom(delay);
    for(i = 0; i < howlong; i++)
      junk = junk * 3 + 1;
    // double the delay
    if(delay < 1000000)
      delay *= 2;
  }

  junkjunk = junk;
}

/*
 * Atomically increment *p and return
 * the previous value.
 */
static __inline unsigned int
ReadAndIncrement(volatile unsigned int *p)
{ 
    int v = 1;
    __asm __volatile (
    "   lock; xaddl   %0, %1 ;    "
    : "+r" (v),
      "=m" (*p)
    : "m" (*p));
 
    return (v);
}


/*
 * Ticket Lock 
 */
void
ticket_acquire(struct lock *lock)
{
  int me = ReadAndIncrement(&lock->next_ticket);
  while(lock->now_serving != me)
    ;
}

void
ticket_release(struct lock *lock)
{
  lock->now_serving += 1;
}

/*
 * Anderson lock
 */
void
anderson_acquire(struct lock *lock)
{
  int myPlace = ReadAndIncrement(&lock->queueLast);
  while(lock->has_lock[myPlace % numprocs].x == 0)
    ;
  lock->has_lock[myPlace % numprocs].x = 0;
  lock->holderPlace = myPlace;
}

void
anderson_release(struct lock *lock)
{
  int nxt = (lock->holderPlace + 1) % numprocs;
  lock->has_lock[nxt].x = 1;
}

/*
 * MCS locks
 */

struct qnode {
    volatile void *next;
    volatile char locked;
    char __pad[0] __attribute__((aligned(CACHELINE)));
};

typedef struct {
    struct qnode *v __align__;
    int lock_idx __align__;
} mcslock;

#define MAX_MCS_LOCKS 3000

extern __thread volatile struct qnode I[MAX_MCS_LOCKS];
extern struct atomic_uint64_t lock_used[MAX_MCS_LOCKS];

static __inline__ uint64_t
cmp_and_swap_atomic(struct atomic_uint64_t *L, uint64_t cmpval, uint64_t newval)
{
    uint64_t out;
    __asm__ volatile(
                "lock; cmpxchgq %2, %1"
                : "=a" (out), "+m" (L->v)
                : "q" (newval), "0"(cmpval)
                : "cc");
    return out == cmpval;
}

static __inline__ uint64_t
fetch_and_store(mcslock *L, uint64_t val) 
{
    __asm__ volatile(
                "lock; xchgq %0, %1\n\t"
                : "+m" (L->v), "+r" (val)
                : 
                : "memory", "cc");
    return val;
}

static __inline__ uint64_t
cmp_and_swap(mcslock *L, uint64_t cmpval, uint64_t newval)
{
    uint64_t out;
    __asm__ volatile(
                "lock; cmpxchgq %2, %1"
                : "=a" (out), "+m" (L->v)
                : "q" (newval), "0"(cmpval)
                : "cc");
    return out == cmpval;
}

void 
mcs_init(mcslock *L)
{
    L->v = NULL;
    for (int i = 0; i < MAX_MCS_LOCKS; i++)
        if (!lock_used[i].v)
            if (cmp_and_swap_atomic(&lock_used[i], 0, 1)) {
                L->lock_idx = i;
                return;
            }
    die("mcs_init: Oops");
}

void
mcs_lock(mcslock *L)
{
    volatile struct qnode *mynode = &I[L->lock_idx];
    mynode->next = NULL;
    struct qnode *predecessor = (struct qnode *)fetch_and_store(L, (uint64_t)mynode);
    if (predecessor) {
        mynode->locked = 1;
        predecessor->next = mynode;
        while (mynode->locked)
            nop_pause();
    }
}

void
mcs_unlock(mcslock *L)
{
    volatile struct qnode *mynode = &I[L->lock_idx];
    if (!mynode->next) {
        if (cmp_and_swap(L, (uint64_t)mynode, 0)) {
            return;
        }
        while (!mynode->next)
            nop_pause();
    }
    ((struct qnode *)mynode->next)->locked = 0;
}
