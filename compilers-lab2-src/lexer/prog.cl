-- Класс Main
class Main inherits IO {
  myVar: Int <- 42;  -- Переменная
  
  myMethod(x: Int): Int {  -- Метод
    if x < myVar then 
      x + 1 
    else 
      x - 1 
    fi
  };

  main(): Object {  -- Точка входа
    out_string("Hello, world!\n")
  };
};
