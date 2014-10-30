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

var milliseconds1 = Date.now(); 
bubble_sort(vec);
var milliseconds2 = Date.now(); 
print(milliseconds2 - milliseconds1);
