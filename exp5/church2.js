(function() {var __contracts, Undefined, Null, Num, Bool, Str, Odd, Even, Pos, Nat, Neg, Self, Any, None, __old_exports, __old_require;
if (typeof(window) !== 'undefined' && window !== null) {
  __contracts = window.Contracts;
} else {
  __contracts = require('contracts.js');
}
Undefined =  __contracts.Undefined;
Null      =  __contracts.Null;
Num       =  __contracts.Num;
Bool      =  __contracts.Bool;
Str       =  __contracts.Str;
Odd       =  __contracts.Odd;
Even      =  __contracts.Even;
Pos       =  __contracts.Pos;
Nat       =  __contracts.Nat;
Neg       =  __contracts.Neg;
Self      =  __contracts.Self;
Any       =  __contracts.Any;
None      =  __contracts.None;

if (typeof(exports) !== 'undefined' && exports !== null) {
  __old_exports = exports;
  exports = __contracts.exports("church2.coffee", __old_exports)
}
if (typeof(require) !== 'undefined' && require !== null) {
  __old_require = require;
  require = function(module) {
    module = __old_require.apply(this, arguments);
    return __contracts.use(module, "church2.coffee");
  };
}
(function() {
  var Church, Proc, c_is_zero, c_star, c_sub1, f_to_n, fact, milliseconds1, n_to_f;

  Proc = (function(x) {
    return typeof x === 'function';
  }).toContract();

  Church = __contracts.fun([__contracts.fun([Any], Any, {})], __contracts.fun([Any], Any, {}), {});

  n_to_f = __contracts.guard(__contracts.fun([Num], Church, {}),function(n) {
    var next;
    if (n === 0) {
      return function(f) {
        return function(x) {
          return x;
        };
      };
    } else {
      next = n_to_f(n - 1);
      return function(f) {
        return function(x) {
          return f(next(f)(x));
        };
      };
    }
  });

  f_to_n = __contracts.guard(__contracts.fun([Church], Num, {}),function(c) {
    return (c((function(x) {
      return x + 1;
    })))(0);
  });

  c_star = __contracts.guard(__contracts.fun([Church], __contracts.fun([Church], Church, {}), {}),function(n1) {
    return function(n2) {
      return function(f) {
        return n1(n2(f));
      };
    };
  });

  c_is_zero = __contracts.guard(__contracts.fun([Church], Bool, {}),function(c) {
    return (c(function(x) {
      return false;
    }))(true);
  });

  c_sub1 = __contracts.guard(__contracts.fun([Church], Church, {}),function(n) {
    return function(f) {
      var X;
      X = function(g) {
        return function(h) {
          return h(g(f));
        };
      };
      return function(x) {
        return ((n(X))(function(u) {
          return x;
        }))(function(u) {
          return u;
        });
      };
    };
  });

  fact = __contracts.guard(__contracts.fun([Church], Church, {}),function(n) {
    if (c_is_zero(n)) {
      return function(f) {
        return f;
      };
    } else {
      return (c_star(n))(fact(c_sub1(n)));
    }
  });

  milliseconds1 = Date.now();

  print(f_to_n(fact(n_to_f(9))));

  print(Date.now(0) - milliseconds1);

}).call(this);
}).call(this);
