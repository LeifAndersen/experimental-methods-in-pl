
var n_to_f = function(n) {
    if (n == 0)
        return function(f) { return function(x) { return x; }}
    else {
        var next = n_to_f(n-1);
        return function(f) { return function(x) { return f(next(f)(x)); }}
    }
}

var f_to_n = function(c) {
    return c(function(x) { return x + 1; })(0);
}

var c_star = function(n1){
    return function (n2) {
        return function(f) {
            return n1(n2(f));
        };
    };
}

var c_is_zero = function(c) {
    return c(function (x){ return false; })(true);
}

// taken from Wikipedia (but lifted out
// the definition of 'X')
var c_sub1 = function(n) {
    return function(f) {
        var X = function(g) { return function(h){ return h(g(f)); }; };
        return function(x) {
            return n(X)(function(u) { return x; })(function(u){ return u; });
        };
    };
}

var fact = function(n){
    if (c_is_zero(n))
        return function(f){ return  f; }
    else
        return c_star(n)(fact(c_sub1(n)));
}

var milliseconds1 = Date.now(); 
print(f_to_n(fact(n_to_f(9))));
var milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);
