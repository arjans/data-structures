from functools import reduce
import math

class Trie:
    def __init__(self, size, hs=None):
        self.hs = hs or list(map(lambda x: Leaf(), [None]*(2**size)))
        self.size = size

    # insert :: Key -> Value -> Hash -> Trie a
    def insert(self, k, v, rh=None):
        rh = rh or bin_hash(k, self.size)
        nh = rh[:self.size]
        i = int(nh, 2)
        xs = self.hs[:]
        if(len(rh) == self.size):
            xs[i] = xs[i].insert(k, v)
        elif(xs[i].is_mt()):
            xs[i] = Trie(self.size).insert(k, v, rh[self.size:])
        else:
            xs[i] = Trie(self.size, xs[i].hs[:]).insert(k, v, rh[self.size:])
        return Trie(self.size, xs)

    # lookup :: Key -> Hash -> Value
    def lookup(self, k, rh=None):
        rh = rh or bin_hash(k, self.size)
        nh = rh[:self.size]
        i = int(nh, 2)
        if(self.hs[i].is_mt()):
            return False
        elif(len(rh) == self.size):
            return search(k, self.hs[i].kvs)
        else:
            return self.hs[i].lookup(k, rh[self.size:])

    # delete :: Key -> Hash -> Trie a
    def delete(self, k):
        exists = self.lookup(k)
        if(not exists):
            return self
        else:
            return self.__delete_helper(k)

    def __delete_helper(self, k, rh=None):
        rh = rh or bin_hash(k, self.size)
        nh = rh[:self.size]
        i = int(nh, 2)
        xs = self.hs[:]
        if(len(rh) == self.size):
            xs[i] = xs[i].delete(k)
        else:
            xs[i] = Trie(self.size, xs[i].hs[:]).__delete_helper(k, rh[self.size:])
        if(all(x.is_mt() for x in xs)):
            return Leaf()
        else:
            return Trie(self.size, xs)

    def keys(self):
        return list(reduce(lambda xs, x: xs + x.keys(), self.hs, []))

    def elems(self):
        return list(reduce(lambda xs, x: xs + x.elems(), self.hs, []))

    def is_mt(self):
        return False

class Leaf:
    def __init__(self, kvs=None):
        self.kvs = kvs

    def insert(self, k, v):
        return Leaf(cons((k, v), self.kvs))

    def delete(self, k):
        return Leaf(delete(k, self.kvs))

    def keys(self):
        return list(map(lambda x: x[0], to_array(self.kvs)))

    def elems(self):
        return list(map(lambda x: x[1], to_array(self.kvs)))

    def is_mt(self):
        return self.kvs == None

def bin_hash(x, size):
    s = math.floor(114/size) * size
    h = str(hash(x))
    return ''.join(format(ord(n), 'b') for n in h)[:s]

''' Linked List '''
def cons(a, b):
    def r(x):
        if(x == 'car'):
            return a
        elif(x == 'cdr'):
            return b
    return r

def car(xs):
    return xs('car')

def cdr(xs):
    return xs('cdr')

def search(k, xs):
    if(xs == None):
        return False
    x = car(xs)
    (xk, xv) = x
    if(xk == k):
        return x
    return search(k, cdr(xs))

def delete(k, xs):
    if(xs == None):
        return None
    x = car(xs)
    (xk, xv) = x
    if(xk == k):
        return cdr(xs)
    return cons(x, delete(k, cdr(xs)))

def to_array(xs):
    if(xs == None):
        return []
    else:
        return [car(xs)] + (to_array(cdr(xs)))

def from_array(xs):
    return foldr(cons, None, xs)

def foldr(f, z, xs):
    return z if not xs else f(xs[0], foldr(f, z, xs[1:]))

t = Trie(4)
xs = [( "a", "b" ),( "c", "d" ), ( "e", "f" )]
t = reduce(lambda z, x: z.insert(*x), xs, t)
