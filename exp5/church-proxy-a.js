
function function_c(object) {
    if (typeof object === "function")
        return object;
    else
        throw "bad proc";
}

function wrap_any(pre, obj) {
    return Proxy.createFunction({ }, 
                                function(x) { return obj(pre(x)); },
                                function() { return 0; }); 
}

function wrap(pre, post, obj) {
    return Proxy.createFunction({ }, 
                                function(x) { return post(obj(pre(x))); },
                                function() { return 0; }); 
}

function proc_c(pre, post) {
    if (post === any_c)
        return function(object) {
            return wrap_any(pre, function_c(object));
        };
    else
        return function(object) {
            return wrap(pre, post, function_c(object));
        };
}

function any_c(obj) {
    return obj;
}

var church_c = proc_c(proc_c(any_c, any_c), 
                      proc_c(any_c, any_c));

function nonnegative_integer_c(obj) {
    if ((obj >= 0) && (Math.round(obj) == obj))
        return obj;
    else
        throw "bad int";
}

function boolean_c(obj) {
    if ((obj == true) || (obj == false))
        return obj;
    else
        throw "bad bool";
}

var n_to_f = proc_c(nonnegative_integer_c, church_c)(
    function(n) {
        if (n == 0)
            return function(f) { return function(x) { return x; }}
        else {
            var next = n_to_f(n-1);            
            return function(f) { 
                var next_f = next(f);
                return function(x) { return f(next_f(x)); };
            };
        }
    });

var f_to_n = proc_c(church_c, nonnegative_integer_c)(
                  function(c) {
                      return c(function(x) { return x + 1; })(0);
                  });

var c_star = proc_c(church_c, proc_c(church_c, church_c))(
                  function(n1){
                      return function (n2) {
                          return function(f) {
                              return n1(n2(f));
                          };
                      };
                  });


var c_is_zero = proc_c(church_c, boolean_c)(
                     function(c) {
                         return c(function (x){ return false; })(true);
                     });

// taken from Wikipedia (but lifted out
// the definition of 'X')
var c_sub1 = proc_c(church_c, church_c)(
                  function(n) {
                      return function(f) {
                          var X = function(g) { return function(h){ return h(g(f)); }; };
                          return function(x) {
                              return n(X)(function(u) { return x; })(function(u){ return u; });
                          };
                      };
                  });

var c_fact = proc_c(church_c, church_c)(
                function(n) {
                    if (c_is_zero(n))
                        return function(f){ return  f; }
                    else
                        return c_star(n)(c_fact(c_sub1(n)));
                });

var milliseconds1 = Date.now(); 
print(f_to_n(c_fact(n_to_f(9))));
var milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);
