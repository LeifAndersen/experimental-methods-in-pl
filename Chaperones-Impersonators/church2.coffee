Church = ?(((Any) -> Any) -> ((Any) -> Any))

n_to_f :: (Num) -> Church
n_to_f = (n) -> 
  if n == 0 
    (f) -> (x) -> x
  else 
    next = n_to_f(n-1)
    (f) -> (x) -> f(next(f)(x))

f_to_n :: (Church) -> Num
f_to_n = (c) -> (c ((x) -> x+1)) 0

c_star :: (Church) -> ((Church) -> Church)
c_star = (n1) -> (n2) -> (f) -> n1 n2 f

c_is_zero :: (Church) -> Bool
c_is_zero = (c) -> (c((x) -> false))(true)

c_sub1 :: (Church) -> Church
c_sub1 = (n) -> (f) ->
  X = (g) -> (h) -> h(g(f))
  (x) -> ((n(X))((u) -> x))((u) -> u)

fact :: (Church) -> Church
fact = (n) -> 
  if c_is_zero n then (f) -> f else (c_star(n))(fact c_sub1 n)

milliseconds1 = Date.now()
print f_to_n fact n_to_f 9
print (Date.now(0) - milliseconds1)