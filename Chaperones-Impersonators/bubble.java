class Bubble {

  static final int SIZE = 10000;

  static int[] make_vec() 
  {
    int i, vec[];

    vec = new int[SIZE];
    for (i = 0; i < SIZE; i++)
      vec[i] = SIZE - i;
    return vec;
  }

  static void bubble_sort(int vec[]) 
  {
    boolean changed = true;
    int i, a, b;
    
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

  public static void main(String args[]) {
    bubble_sort(make_vec());
  }
}

