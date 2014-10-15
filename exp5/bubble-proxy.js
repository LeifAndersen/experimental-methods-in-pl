//(function(){
var SIZE = 10000;

function make_vec(SIZE) {
    var vec = new Array(SIZE);
    for (i = 0; i < SIZE; i++)
        vec[i] = SIZE - i;
    return vec;
}

function bubble_sort(vec)
{
    var changed = true;
    var i, a, b;
    
    while (changed) {
        changed = false;
        
        for (i = 0; i < SIZE - 1; i++) {
            a = vec[i];
            b = vec[i+1];
            if (a > b) {
                vec[i] = b;
                vec[i+1] = a;
                changed = true;
            }
        }
    }
}

var vec = make_vec(SIZE);

// from Van Custem & Miller (DLS 2010):
function makeForwardingHandler(target) { 
    return {
        get: function(rcvr,name) { return target[name];},
        set: function(rcvr,name,val) { target[name] = val; return true; },
        has: function(name) { return name in target; },
        delete : function(name) { return delete target[name]; }
    };
}

var proxy = Proxy.create({
    get: function(rcvr,name) { return vec[name];},
    set: function(rcvr,name,val) { vec[name] = val; return true; },
    has: function(name) { return name in vec; },
    delete : function(name) { return delete vec[name]; } },
                         Object.getPrototypeOf(vec));

var milliseconds1 = Date.now(); 
bubble_sort(proxy);
var milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);
//})()