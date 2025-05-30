---
layout: intro
---

# Язык программирования Go
## Структура программы
### Анатолий Никифоров, OTUS, 2025
#### Лекция 2

---
layout: section
---

# Имена

---

# 25 ключевых слов

```
break     default      func    interface  select
case      defer        go      map        struct
chan      else         goto    package    switch
const     fallthrough  if      range      type
continue  for          import  return     var
```

---

- PascalCase и camelCase
- Имена начинаются с букв (по Unicode) или с нижнего подчеркивания
- В именах допустимы цифры и нижние подчеркивания
- Регистр имеет значение: `sortArray` и `Sortarray` – разные имена

---

# Предварительно объявленные имена

<div class="text-xs">
    <div class="flex">
        <div class="flex-col text-base">
            Константы:
        </div>
        <div class="flex-col font-mono self-center mx-1">
            true  false  iota  nil
        </div>
    </div>
    <div class="flex">
        <div class="flex-col text-base">
            <div class="container mr-10 pt-4">
                Типы:
            </div>
        </div>
        <div class="flex-col font-mono mx-1">
            <p>
                int  int8  int16  int32  int64
            </p>
            <p>
                uint  uint8  uint16  uint32  uint64  uintptr
            </p>
            <p>
                float32  float64  complex128  complex64
            </p>
            <p>
                bool  byte  rune  string  error
            </p>
            <p>
                any
            </p>
        </div>
    </div>
    <div class="flex">
        <div class="flex-col text-base">
            <div class="container mr-2 pt-4">
                Функции:
            </div>
        </div>
        <div class="flex-col font-mono mx-1">
            <p>
                make  len  cap  new  append  copy  close
            </p>
            <p>
                delete
            </p>
            <p>
                complex  real  imag
            </p>
            <p>
                panic  recover
            </p>
        </div>
    </div>
</div>

---
---
# Еще об именах

<v-clicks>

- Предварительно объявленные имена не зарезервированы (доступны для объявлений).
- Сущность, объявленная в функции, _локальна_ для этой функции.
- Сущность, объявленная вне функции, видима во всех файлах пакета, которому она принадлежит.
- Первая заглавная буква объявления _экспортирует_ объявленную сущность в другие пакеты.
- Имена пакетов всегда в нижнем регистре
- Короткие имена предпочтительны по соглашению
- Длинные имена предполагают особую смысловую нагрузку
- camel case и никакого snake case
    - **Хорошо**: `parseRequestDate`
    - **Плохо**: `parse_request_date`
- Аббревиатуры (HTML) остаются в верхнем регистре:
    - **Хорошо**: `ExportHTML`
    - **Плохо**: `ExportHtml`

</v-clicks>

---
layout: section
---

# Объявления

---

- 4 главных типа объявлений: `var const type func`
- Исходный код программы хранится в одном и более файлах с расширением `.go`
- Каждый файл начинается с объявления `package` - пакет, частью которого является файл
- После `package` следуют объявления любых `import`
- После `import` следуют объявления на уровне пакета (типы, переменные, константы, функции)

---
layout: two-cols
---

# Пример

```go
package main

import "fmt"

const Pi float64 = 3.14

func main() {
	var r float64 = 10.0
	var c float64 = 2.0 * Pi * r
	fmt.Println(c)
}
```

::right::

<div class="pt-14 pl-8">
    <ul>
        <li>Константа <span class="font-mono">Pi</span> объявлена на уровне пакета <span class="font-mono">main</span></li>
        <li>Переменные <span class="font-mono">r</span> и <span class="font-mono">c</span> локальны для функции <span class="font-mono">main</span></li>
        <li><span class="font-mono">Pi</span> видна во всех файлах пакета <span class="font-mono">main</span></li>
        <li><span class="font-mono">r</span> и <span class="font-mono">c</span> видны только в функции <span class="font-mono">main</span></li>
    </ul>
</div>

---
layout: two-cols
---

# Пример

```go
// Circumference calculation.
package main

import "fmt"

func main() {
    const Pi float64 = 3.14
    const r1 float64 = 1.0
    const r2 float64 = 2.0
    fmt.Println(circumference(r1)) // +6.280000e+000
    fmt.Println(circumference(r2))   // +1.256000e+001
}

func circumference(r float64) float64 {
    return 2.0 * Pi * r
}
```



::right::

<div class="pt-14 pl-8">
    <ul>
        <li>Объявление функции может включать опциональный список результатов</li>
        <li>Объявление параметров функции сопровождается указанием типов</li>
        <li>Если функция ничего не возвращает, список результатов в объявлении опускается.</li>
    </ul>
</div>
---
layout: section
---

# Переменные

---

Объявление `var` создает переменную определенного типа, задает ей имя и устанавливает начальное значение.

## Общая форма

var _имя_ _тип_ = _выражение_

- Можно опустить либо тип, либо выражение
- Если опущен тип, он определяется из выражения
- Если опущено выражение, то в переменную заносится нулевое значение (`0`, `""`, `false`, `nil`)

### Пример

```go
var s string
fmt.Println(s) // ""
```

---

# Порядок инициализации

- Переменные на уровне пакета инициализируются до начала функции `main`
- Локальные переменные инициализируются по мере достижения исполнения их функций

---

# Множественное объявление переменных

```go
var a, b, c int                 // int, int, int
var x, y, z = false, 0.1, "hello" // bool, float64, string
```



## Возвращаемые значения функции в качестве значений множества переменных

```go
var file, err = os.Open("file.go") // os.Open возвращает файл и ошибку
```

---

# Короткие объявления переменных

- Доступны для локальных переменных (внутри функций)

## Общая форма

_имя_ := _выражение_

## Пример

```go
p := person{"Bob", 20}
freq := rand.Int() * 2
x := 1.0
```

---

# Короткое объявление vs `var`

Объявления типа `var` можно использовать для локальных переменных, когда необходимо задать тип с нулевым значением, которое будет меняться позже.

## Пример 1

Пустой список, который будет заполняться позже

```go
var countries []string 
```

## Пример 2

Инициализация структуры со значением `nil`

```go
var c Country
```

---

# Множественная инициализация в коротком объявлении

```go
a, b := 1, 2
```

## Swap

```go
a, b = b, a
```

## Переменные в коротком объявлении могут принимать множество значений из функции

```go
file, err := os.Open("file.go")

if err != nil {
    return err
}
// ...использовать файл...
file.Close()
```

---

# Повторные присваивания в коротких объявлениях

- Если переменные в коротком объявлении были объявлены ранее, то они получают новые значения.
- Короткое объявление должно содержать хотя-бы одну новую переменную

# Пример 1

Второе объявление присвоит новое значение переменной `err`

```go
i, err := os.Open("input")
// ...
o, err := os.Create("output")
```

---

# Пример 2

```go
file, err := os.Open("input")
// ...
file, err := os.Create("output") // ошибка компиляции: нет новых переменных
```

<v-clicks>

## Fix

```go
file, err := os.Open("input")
// ...
file, err = os.Create("output")
```

</v-clicks>

---

# Указатели

```go
num := 1
nump := &num        // nump, типа *int, указывает на num
fmt.Println(*nump) // "1"
*nump = 0          // эквивалентно num = 0
fmt.Println(num)  // "0"
```

<v-clicks>

- `nump != nil` если `nump` ведет к переменной
- два указателя равны если они ведут к одной переменой

```go
var a, b int
fmt.Println(&a == &a) // true
fmt.Println(&a == &b) // false
fmt.Println(&a == nil) // false
```

</v-clicks>

---

# Для функции безопасно возвращать указатель

```go
var p = getP()

func getP() *string {
    val := "hello"
    return &val
}
```

<v-clicks>

Переменная `val` инициализируется при каждом вызове функции `getP()` в разных ячейках памяти:

```go
p1 = getP()
p2 = getP()
fmt.Println(p1 == p2) // "false"
```

</v-clicks>

---
layout: two-cols
---

# Пакет flag

```go
// cmd.go
package main

import (
    "flag"
    "fmt"
)

func main() {
    arg := flag.String("word", "", "a string")
    flag.Parse()
    fmt.Println(*arg)
}
```

::right::

<div class="pt-16 pl-8">

```
$ go build cmd.go
$ ./cmd -word=hello
hello
$ ./cmd

$ ./cmd -help
Usage of ./cmd:
  -word="": a string
```

</div>

---

# Функция new

- Еще один способ создания переменной
- `new(T)` создает *безымянную* переменную типа `T` c нулевым значением и возвращает ее адрес – значение типа `*T`
- Используется редко

---

# Пример

```go
p := new(string)   // p, типа *string, указывает на безымянную переменную string
fmt.Println(*p) // пустая строка
*p = "hello"         // присваивает значение "hello"
fmt.Println(*p) // "hello"
```

## Это всего лишь синтаксическое соглашение!
- удобно использовать в выражениях

---
---
# Эти функции эквивалентны

```go
func newString() *string {
    return new(string)
}
```

```go
func newString(){
    var emptyString string
    return &emptyString
}
```

<v-clicks>

## Каждый вызов `new` возвращает отдельную переменную с новым адресом

```go
p1 := new(int)
p2 := new(int)
fmt.Println(p1 == p2) // "false"
```

</v-clicks>

---

# Время жизни переменных

- Переменные, объявленные на уровне пакета, живут все время исполнения программы
- Локальные переменные живут до тех пор, пока не станут _недоступными_

---

# Пример

```go
nums := make(map[int]int)

for i := 1; i < 10; i++ {
    index := i - 1
    nums[index] = i
}
```

<v-clicks>

- Переменная `i` создается один раз, когда начинает исполняться цикл `for`
- Переменные `index` создается при каждой итерации
- Переменная становится недоступной, когда не существует пути к ее значению

</v-clicks>

---

# Выделение памяти

Компилятор выделяет память для локальных переменных в стеке или в куче. Есть специальный алгоритм, который решает, куда положить переменную. Вручную этим управлять нельзя.

```go
var T *int

func tie() {
    var p int
    p = 10
    T = &p
}
```

- `p` выделяется в куче потому, что она доступна из `T` после возврата `tie`

```go
func pure() {
    x := new(int)
    *x = 10
}
```

- `x` выделяется в стеке потому, что она недоступна после возврата `pure`
---
layout: section
---

# Присваивания

---

```go
x = 10                       // именованная переменная
*p = false                   // непрямая переменная
country.city = "beijing"         // поле структуры
nums[x] = nums[x] * coefficient // элемент массива, slice или map
```

Каждый арифметический и побитовый оператор имеет соответствующий _оператор присваивания_:

```go
nums[x] *= coefficient
```

## Инкременты и декременты

```go
a := 1
a++    // a = a + 1; a == 2
a--    // a = a - 1; a == 1
```

---

# Кортежные присваивания

```go
a, b = b, a
```

## Пример 1

```go
func GCD(a, b int) int {
    for b != 0 {
        a, b = b, a%b
    }
    return a
}
```

## Пример 2

```go
func Fibonacci(n int) int {
    a, b := 0, 1
    for i := 0; i < n; i++ {
        a, b = b, a+b
    }
    return a
}
```
---
---
# Кортежные присваивания при вызове функций

```go
file, err = os.Open("report.md")  // функция возвращает два значения
```

Часто функции возвращают дополнительные значения: ошибку или булевый тип, отражающий результат.

```go
val, ok = vals[k]  // поиск в map
val, ok = y.(T)   // проверка типа
val, ok = <-ch    // получение значения из канала
```

## Пустой идентификатор
Ненужные значения можно отбросить

```go
_, err := io.WriteString(file, "hello") // отбросить количество записанных байтов
_, ok = x.(T)                           // проверить тип, но отбросить результат
```
---

# Неявные присваивания

```go
colors := []string{"green", "red", "blue"}
```

# Явные присваивания

```go
colors[0] = "green"
colors[1] = "red"
colors[2] = "blue"
```

# Правило присваивания

Присвоить значение переменной можно только если тип переменной совпадает со значением.

---
layout: section
---

# Объявления типов

---

- Объявление `type` определяет новый *именованный тип*
- Именованный тип содержит базовый тип в определении

---

# Общая форма

type *имя* *базовый_тип*

---

# Пример

```go
package main
 
import "fmt"

type Mile float64
type Kilometer float64
 
func MIToKM(m Mile) Kilometer {
   return Kilometer(m * 1.609)
}

func KMToMI(k Kilometer) Mile {
   return Mile(k / 1.609)
}
```

<v-clicks>

- `Mile` и `Kilometer` – разные типы, несмотря на общий базовый тип
- Между ними запрещена арифметика и логика

</v-clicks>

---

# Выводы

<v-clicks>

- Для каждого типа `T` существует соответствующая операция преобразования `T(x)`, которая преобразовывает значение `x` в тип `T`.
- Преобразование из одного типа в другой разрешено только если оба именованных типа имеют общий базовый тип
- Такое преобразование не меняет представление значения, а только тип
- Именованный тип можно сравнить с самим собой или с его базовым типом

</v-clicks>

---

# Пример

```go
var m Mile
var k Kilometer

fmt.Println(m == 0) // true
fmt.Println(k >= 0) // true
fmt.Println(m == k) // compile error: type mismatch
fmt.Println(m == Mile(k)) // true
```

---

# Методы именованных типов

```go
func (m Mile) String() string {
	return fmt.Sprintf("%g mi", m)
}
```

- Именованные типы обладают поведением, которое можно программировать с помощью множества функций, называемых методами.
- Метод `String` отвечает за строковое представление значения типа.

---

# Пример

```go
k := MToKM(10.0)
fmt.Println(k.String()) // 16.09 km
fmt.Printf("%v\n", k)   // 16.09 km; необязательно явно вызывать String
fmt.Printf("%s\n", k)   // 16.09 km
fmt.Println(k)          // 16.09 km
fmt.Printf("%g\n", k)   // 16.09; не вызывает String
fmt.Println(float64(k)) // 16.09; не вызывает String
```
---
layout: section
---

# Пакеты и файлы

---

<v-clicks>

- Пакеты – аналог библиотек или модулей из других языков
- Они поддерживают модульность, инкапсуляцию, раздельную компиляцию и повторное использование
- Исходный код пакета хранится в одном или более файлов с расширением `.go`
- Каждый пакет служит пространоством имен для собственных объявлений
- Имена в пакетах можно скрывать или *экспортировать*

</v-clicks>

---

# Правило

Чтобы экспортировать имя из пакета, достаточно написать его с заглавной буквы.

---

# Пример

Пусть, наш пакет называется `github.com/username/distconv` и соостоит из двух файлов.

---
layout: two-cols
---

# `distconv.go`

```go
// Пакет distconv производит преобразования милей и километров.
package distconv
 
import "fmt"

type Mile float64
type Kilometer float64

const SoLKMS = 1.079e+9
const SoLMIS = 6.706e+8

func (m Mile) String() string {
	return fmt.Sprintf("%g mi", m)
}

func (k Kilometer) String() string {
	return fmt.Sprintf("%g km", k)
}
```

::right::

# `conv.go`

```go
package distconv

func MIToKM(m Mile) Kilometer {
   return Kilometer(m * 1.609)
}

func KMToMI(k Kilometer) Mile {
   return Mile(k / 1.609)
}
```

---

<v-clicks>

- Каждый файл начинается с объявления `package`
- При импортировании пакета, обращения к именам имеют вид `distconv.MIToKM`
- Так как типы и константы объявлены с заглавной буквы, они видны во всех других файлах пакета так, как-будто они находятся в едином файле исходного кода
- Комментарий в начале пакета является документацией пакета
- Только один файл должен в пакете может содержать документацию всего пакета
- Расширенная документация помещается в `doc.go`  

</v-clicks>

---

Так как объявления `const` начинаются с заглавных букв, они доступны по имени пакета:

```go
fmt.Printf("Время для нас течет медленней при нашей скорости %v/sec. \n", distconv.SoLKMS) // Время для нас течет медленней при нашей скорости 1.079e+9 km/sec.
```

---

Чтобы преобразовать мили в километры в пакете, который импортирует `github.com/username/distconv`:

```go
fmt.Println(distconv.MIToKM(distconv.Mile(12.0))) // 19.308 km
```

---
layout: section
---

# Импорты

---

<v-clicks>

- Каждый пакет идентифицируется по его *пути импорта* (import path)
- Путь импорта есть строка в объявлении `import`, например, `github.com/username/distconv`
- Путь импорта пакета != имя пакета
- Имя пакета – это то, что содержится в объявлении `package`
- По соглашению имя пакета совпадает с последним сегментом пути импорта: `github.com/username/distconv` это путь импорта пакета `distconv`

</v-clicks>

---

# Чтобы использовать `distconv`, надо его импортировать

```go
// MK конвертирует числовые аргументы в мили и километры

import (
    "fmt"
    "os"
    "strconv"

    "github.com/username/distconv"
)

func main() {
    for _, arg := range os.Args[1:] {
        t, err := strconv.ParseFloat(arg, 64)
        if err != nil {
            fmt.Fprintf(os.Stderr, "mk: %v\n", err)
            os.Exit(1)
        }
        m := distconv.Mile(t)
        k := distconv.Kilometer(t)
        fmt.Printf("%s = %s, %s = %s\n",
            m, distconv.MIToKM(m), k, distconv.KMToMI(k))
    }
}
```

---

<v-clicks>

- Объявление `import` связывает импортированный пакет с его коротким именем
- Через это имя можно ссылаться на имена пакета (`distconv.MIToKM`)
- Пакету можно указывать альтернативное имя при импорте во избежание конфликтов

</v-clicks>

---

# Программа mk конвертирует числовые аргументы в мили и километры

```
$ go build github.com/username/mk

$ ./mk 10
10 mi = 16.09 km, 10 km = 6.215040397762586 mi
$ ./mk 100
100 mi = 160.9 km, 100 km = 62.15040397762586 mi
$ ./mk 1000
1000 mi = 1609 km, 1000 km = 621.5040397762585 mi
```

---

<v-clicks>

- Импорт пакета без обращения к нему является ошибкой
- Это помогает бороться с ненужными зависимостями
- [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) управляет объявлениями `import` автоматически

</v-clicks>

---
layout: section
---

# Инициализация пакетов

---

Инициализация пакета начинается с переменных, объявленных на уровне пакета в порядке их объявления, за исключением зависимостей, которые разрешаются в первую очередь.

```go
var x = y + z     // x инициализируется третьей, как 3
var y = f()       // y инициализируется второй, как 2, вызывая функцию f
var z = 1         // z инициализируется первой, как 1

func f() int { return z + 1 }
```

<v-clicks>

- Если пакет состоит из множества файлов `.go`, то они инициализируются в том порядке, в котором они предоставляются компилятору
- Утилита `go` сортирует файлы `.go` по имени перед вызовом компилятора
</v-clicks>

---

Для некоторых переменных, выражения инициализации могут быть не самым легким способом задать начальные значения.

```go
package main

import "fmt"

var vals [10]int

func init() {
	for i := 0; i < 10; i++ {
		vals[i] = i
	}
}

func main() {
	fmt.Println(vals) // [0 1 2 3 4 5 6 7 8 9]
}
```

---
layout: section
---

# Области видимости

---

# Определение

Область видимости объявления – это часть исходного кода, в которой использование объявленного имени ведет к этому объявлению.

<v-clicks>

- Область видимости != время жизни
- Область видимости объявления – это область программного кода
- Время жизни – это промежуток во время исполнения, когда к переменной можно обратиться

</v-clicks>

---

# Блоки

<v-clicks>

- Синтаксический блок – последовательность объявлений, заключенная в фигурные скобки
- Имя объявленное внутри синтаксического блока невидимо снаружи блока
- Блок содержит объявления и определяет их область видимости
- Существуют:
    - Универсальный блок
    - Блоки `for`, `if`, `switch` и т.п.


</v-clicks>

---

# Затененные переменные 

- В каждом блоке можно объявлять имя, существующее в других блоках
- Компилятор ищет объявление начиная с самого внутреннего блока

```go
func f() {}

var x = "x"

func main() {
    f := "f"
    fmt.Println(f) // "f"; локальная f затеняет пакетную f
    fmt.Println(x) // "g"; переменная пакетного уровня
    fmt.Println(y) // compile error: undefined: h
}
```

---

# Неявные блоки

```go
func main() {
    a := "world!"
    for i := 0; i < len(x); i++ {
        a := a[i]
        if a != '!' {
            a := a + 'A' - 'a'
            fmt.Printf("%c", a) // WORLD
        }
    }
}
```

<v-clicks>

- Тело цикла `for` образует явный блок
- Объявление `for` содержит неявный блок инициализации переменной `i`

</v-clicks>

---

# Пример 1 (область видимости)

```go
if a := f(); a == 0 {
    fmt.Println(a)
} else if b := g(a); a == b {
    fmt.Println(a, b)
} else {
    fmt.Println(a, b)
}
fmt.Println(a, b) // compile error: a and b здесь не видны
```

---

# Пример 2

```go
if file, err := os.Open(filename); err != nil { // compile error: unused: file
    return err
}
file.ReadByte() // compile error: undefined file
file.Close()    // compile error: undefined file
```

## Fix 1

```go
file, err := os.Open(filename)
if err != nil {
    return err
}
file.ReadByte()
file.Close()
```

## Fix 2

```go
if file, err := os.Open(filename); err != nil {
    return err
} else {
    file.ReadByte()
    file.Close()
}
```
---
layout: end
---
