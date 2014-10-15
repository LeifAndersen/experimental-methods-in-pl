
function loop(f) {
    for (i = 0; i < 100000000; i++) {
        f.weight;
    }
}

var fish = { weight : 1, color : "blue" };

print("direct");
milliseconds1 = Date.now(); 
loop(fish);
milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);

var proxy = Proxy.create({
    get: function(rcvr,name) { return fish[name];},
    set: function(rcvr,name,val) { fish[name] = val; return true; },
    has: function(name) { return name in fish; },
    delete : function(name) { return delete fish[name]; } },
                         Object.getPrototypeOf(fish));


print("proxy");
milliseconds1 = Date.now(); 
loop(proxy);
milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);

