---
layout: intro
---

# Язык программирования Go
## Составные типы данных
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 4

---
layout: section
---

# Массивы

---
layout: fact
---
Используются редко из-за фиксированной длины, в отличие от срезов
---

# Пример

```go
var a [6]int             // массив из 6 целых чисел
fmt.Println(a[0])        // напечатать первый элемент
fmt.Println(a[len(a)-1]) // напечатать последний элемент, a[5]

// Напечатать индексы с элементами.
for i, v := range a {
    fmt.Println(i, v)
}

// Напечатать только элементы.
for _, v := range a {
    fmt.Println(v)
}
```

- Отдельные элементы массива доступны по индексной записи
- Индекс не меньше нуля и не больше длины массива - 1
- len возвращает количество элементов в массиве
- По-умолчанию все элементы нового массива равны нулевому типу объявленного типа

---

# Литерал массива

```go
var a = [2]string{"hello", "world"}
fmt.Println(a[1]) // world
```

---

# Многоточие

```go
a = [...]string{"hello", "world", "!"}
fmt.Println(r[2]) // !
```

---
layout: fact
---

Длина массива – это часть его типа, поэтому [3]int != [4]int

---

# Пример

```go
a := [2]string{"hello", "world"}
a = [3]string{"hello", "world", "!"} // ошибка компиляции
```

---

# Пары индекс-значение в объявлении

```go
type Scale int

const (
	CELSIUS Scale = iota
	FAHRENHEIT
	KELVIN
)

temp := [...]string{CELSIUS: "°C", FAHRENHEIT: "°F", KELVIN: "K"}
fmt.Println(KELVIN, temp[KELVIN]) // 2 K
```

<!-- iota – это enum -->

---

# Можно указывать индексы в любом порядке

```go
a := [...]int{999: 1}
```

---
layout: fact
---

Если тип элемента массива сравниваемый, то и сам массив можно сравнить

---

# Пример

```go
a := [2]string{"hello", "world"}
b := [...]string{"hello", "world"}
c := [2]string{"hello", "Bob"}
fmt.Println(a == b, a == c, b == c) // true false false
```

---

# Еще пример

```go
import (
	"crypto/md5"
	"fmt"
)

func main() {
	s1 := md5.Sum([]byte("a"))
	s2 := md5.Sum([]byte("A"))
	fmt.Printf("%x\n%x\n%v\n%T", s1, s2, s1 == s2, s1)
}
```

<br>

## Вывод

<br>

```
0cc175b9c0f1b6a831c399e269772661
7fc56270e7a70fa81a5935b72eacbe29
false
[16]uint8
```

<!-- s1 и s2 – массивы байтов -->

---
layout: section
---

# Срезы

---

- Срез объявляется как []T (без длины)
- Срез предоставляет доступ к нижележащем массиву или части массива

## Компоненты среза

- Указатель (pointer)
- Длина (length)
- Вместимость (capacity)

---

# Указатель

- Указатель ведет к первому элементу среза
- Первый элемент среза необязательно является первым элементом нижележащего массива

---

# Длина

- Количество элементов среза
- Может превышать вместимость (capacity)
- Функция len

---

# Вместимость

- Число элементов между началом среза и концом нижележащего массива
- Функция cap

---

Множество срезов могут ссылаться на один массив и иметь пересекающиеся элементы

<img class="px-48" src="/public/Untitled drawing (2).png"/>

---

# Пример

```go
s := []string{"", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"}
q1 := s[2:5]
q2 := s[4:7]
fmt.Println(q1) // [Вторник Среда Четверг]
fmt.Println(q2) // [Четверг Пятница Суббота]

// анонимная функция
fmt.Println(func(q1 []string, q2 []string) []string {
	var i []string

	for _, k := range q1 {
		for _, j := range q2 {
			if k == j {
				i = append(i, k)
			}
		}
	}

	return i
}(q1, q2)) // [Четверг]
```

<!-- Не самый эффективный способ -->

---

# Срез превышающий cap(s) недопустим

```go
fmt.Println(q1[:14]) // паника
```


# Срез превышающий len(s) расширяет s

```go
fmt.Println(q1[:6]) // [Вторник Среда Четверг Пятница Суббота Воскресенье]
```

<!-- Заполняется значениями из нижележащего массива -->

---

# Передача среза в функцию

```go
a := [...]int{1, 2, 3, 4, 5, 6, 7} // массив

func(s []int) {
	for i := range s {
		s[i] = 0
	}
}(a[:]) // передача среза

fmt.Println(a) // [0 0 0 0 0 0 0]
```

<!-- Функция получает доступ к нижележащему массиву среза. -->

---

# Некоторые ограничения

- Срезы нельзя сравнивать между собой
- Срезы можно сравнивать только с nil
- Можно написать функцию сравнения двух срезов

<!-- срезы нельзя сравнивать потому, что под ними расположен изменяемый массив, это бы повлекло за собой изменение поведения операции сравнения, поэтому проще было запретить -->

---

# Нулевое значение среза

```go
var s []int // s == nil, len(s) == 0
s = []int{} // s != nil, len(s) == 0
```

Проверяйте пустой срез через len(s) == 0

---

# Функция make

make(T[], len, cap)

Создает безымянный массив и возвращает его срез.

---
layout: section
---

# Функция append

---

# Пример

```go
var s []int
	for i := 0; i < 10; i++ {
		fmt.Printf("итерация=%d\tcapacity=%d\t%v\n", i, cap(s), s)
		s = append(s, i)
	}
```

## Вывод

```text
итерация=0	capacity=0	[]
итерация=1	capacity=1	[0]
итерация=2	capacity=2	[0 1]
итерация=3	capacity=4	[0 1 2]
итерация=4	capacity=4	[0 1 2 3]
итерация=5	capacity=8	[0 1 2 3 4]
итерация=6	capacity=8	[0 1 2 3 4 5]
итерация=7	capacity=8	[0 1 2 3 4 5 6]
итерация=8	capacity=8	[0 1 2 3 4 5 6 7]
итерация=9	capacity=16	[0 1 2 3 4 5 6 7 8]
```

---

# Алгоритм

1. append берет cap(s)
2. Проверяет вместимость нижележащего массива s
3. Если в нижележащем массиве есть место, то расширить срез и положить туда новый элемент
4. Если места нет, то выделить память под новый массив двойной длины от старого массива
5. Скопировать значения из старого массива в новый
6. Положить туда новый элемент
7. Вернуть срез, который ссылается на новый массив

---

# Пример

```go
s := []int{1}
s = append(s, 2)
```

Можно перезаписать старый срез чтобы не хранить в памяти два разных массива.

---
layout: section
---

# Maps

---

# Общая форма

map[K]V, где K – типа ключей, V – тип значений

- Ключами могут быть только сравниваемые типы
- На значения ограничений нет

---

# Создание map

## Функция make

```go
phoneticAlphabet := make(map[string]int)
```

## Литерал

```go
phoneticAlphabet := map[string]int{
	"Alpha": 1,
	"Bravo": 2,
	"Charlie": 3,
	}
```

## Явно

```go
phoneticAlphabet := make(map[string]int)
phoneticAlphabet["Alpha"] = 1
phoneticAlphabet["Bravo"] = 2
phoneticAlphabet["Charlie"] = 3
```

## Пустая map

```go
phoneticAlphabet := map[string]int{}
```

---

# Доступ к значениям

```go
fmt.Println(phoneticAlphabet["Bravo"]) // 2
```

# Удалить элемент

```go
delete(phoneticAlphabet, "Alpha")
```

Если элемента нету в map, то возвращается нулевой тип ключа (все операции безопасны)

```go
fmt.Println(phoneticAlphabet["Delta"]) // 0
phoneticAlphabet["Delta"] += 4
fmt.Println(phoneticAlphabet["Delta"]) // 4
```

---

# Итерация

```go
for codeword, pos := range phoneticAlphabet{
	fmt.Println(codeword, pos)
}
```

# Наличие элемента

```go
codeword, ok := phoneticAlphabet["Echo"]

if !ok {
	/* Echo is down! */
}

// ИЛИ

if codeword, ok := phoneticAlphabet["Echo"]; !ok {
	/* Echo is down! */
	}

```

---

# Map as Set

```go
// Новый пустой набор
set := make(map[string]bool) 

// Добавить
set["Alpha"] = true       

// Итерировать
for a := range set {
	fmt.Println(a)
}

// Удалить
delete(set, "Alpha")

// Размер
size := len(set)

// Вхождение
exists := set["Alpha"]
```

---
layout: section
---

## Внутреннее устройство map

---

# Простая реализация

```go
type entry struct {
   k string
   v float64
}

type map []entry

func lookup(m map, k string) float64 {
	for _, e := range m {
		if e.k == k {
			return e.v
			}
    }
	return 0
}
```
---
layout: fact
---

## Медленно! O(n)

---
layout: center
---

# Идея

<img src="https://live.staticflickr.com/2325/2392260426_e22e062694.jpg"/>

<!-- Что такое контейнеры? Зачем они нужны? Они используются во всех хэш таблицах.  -->

---

# Идея: разбить на контейнеры

<img class="px-48" src="Untitled drawing (6).png"/>

<!-- Положить в контейнер на основании первой буквы ключа. На картинке идеальное представление – оно работает, только если у ключей разные первые буквы -->

---
layout: fact
---

## Быстро, но...

---

# Распределение по первой букве работает плохо

Есть ли способ лучше?

<img class="px-48" src="Untitled drawing (7).png"/>

---

# Хэширующая функция

Выбрать контейнер для каждого ключа таким образом, чтобы записи распределялись наиболее равномерно.

**bucket = h(key)**

## Требования к корректности

- Детерминированность:	**k1 == k2 → h(k1) == h(k2)**

## Требования к производительности

- Постоянство:	Вероятность **[h(k) == b]** ~= 1/#buckets
- Скорость: **h(k)** должна быть быстрой
- Безопасность: для атакующего сложно найти множество **k** имея **h(k) == b**

<!-- Не говорить много, хэширующие функции отдельная тема криптографии -->

---
layout: two-cols
---

# Map bucket in Go

<img  src="/public/Untitled drawing (8).png"/>

::right::

<div class="mt-32">

- 8 слотов под данные
- e - дополнительные биты для различия записей в рамках одного контейнера
- overflow – указатель на другой контейнер, если нужно больше восьми слотов

</div>

---
layout: two-cols
---

# Map in Go

<img src="/public/Untitled drawing (10).png">

::right::

<div class="mt-32">


```go
var m map[string]float64
```

</div>

<!-- map – это всего лишь указатель на заголовок -->

---

# Эвакуация map

Если в каждом контейнере в среднем более 6,5 элементов, происходит увеличение массива buckets. При этом выделяется массив в 2 раза больше, а старые данные копируются в него маленькими порциями каждые вставку или удаление, чтобы не создавать очень крупные задержки. Поэтому все операции будут чуть медленнее в процессе эвакуации данных (при поиске тоже, нам же приходится искать в двух местах). После успешной эвакуации начинают использоваться новые данные.

```go
// A header for a Go map.
type hmap struct {
	// Note: the format of the hmap is also encoded in cmd/compile/internal/reflectdata/reflect.go.
	// Make sure this stays in sync with the compiler's definition.
	count     int // # live cells == size of map.  Must be first (used by len() builtin)
	flags     uint8
	B         uint8  // log_2 of # of buckets (can hold up to loadFactor * 2^B items)
	noverflow uint16 // approximate number of overflow buckets; see incrnoverflow for details
	hash0     uint32 // hash seed

	buckets    unsafe.Pointer // array of 2^B Buckets. may be nil if count==0.
	oldbuckets unsafe.Pointer // previous bucket array of half the size, non-nil only when growing
	nevacuate  uintptr        // progress counter for evacuation (buckets less than this have been evacuated)

	extra *mapextra // optional fields
}
```

<!-- Не говорить об этом много, эвакуация – аллокация нового buckets array. Как и в случае слайса размер увеличивается в два раза. oldbuckets указывает на массив до эвакуации. -->

---
layout: center
---

<!-- # Reference -->

### GopherCon 2016: Keith Randall - Inside the Map Implementation

<br>

<Youtube id="Tl7mi9QmLns" width="800" height="400"/>

---

# Статья

<br>

<a href="https://dave.cheney.net/2018/05/29/how-the-go-runtime-implements-maps-efficiently-without-generics/">
	How the Go runtime implements maps efficiently (without generics)
</a> (Dave Cheney)

---
layout: section
---

# Структуры

---

# Пример

Структура – это тип, объединяющий переменные разного типа в единую сущность.

```go
type User struct{
	ID int
	Email string
	Password string
	LastLogin time.Time
	Registered time.Time
	IsAdmin bool
}

var user User
user.LastLogin = time.Now() 	// прямой доступ по точечному обозначению
email := &user.Email
*email = "example@email.com"	// доступ по указателю
fmt.Println(user.Email)			// example@email.com
var admin *User = &user			// точечное обозначение работает и с указателем на структуру
admin.IsAdmin = true
fmt.Println(user.IsAdmin)		// true
```

- Структура состоит из полей
- Структура экспортируется заглавной буквой в своем названии
- Поля экспортируются также

---

# Еще пример

```go
func UserByID(id int) *{
	/* ... */
}

id := user.ID	
UserByID(id).IsAdmin = false
```


<!-- Последняя инструкция обновляет структуру User, на которую указывает
результат вызова UserByID. Если тип результата UserByID изменить на
User вместо *User, инструкция присваивания не будет компилироваться,
поскольку ее левая сторона не будет определять переменную. -->

---

# Поля одинакового типа можно комбинировать

```go
type User struct{
	ID int
	Email, Password string
	LastLogin, Registered time.Time
	IsAdmin bool
}
```

Порядок полей критичен для идентификации структуры

---

# Рекурсивные типы данных

```go
type Node struct {
    left  *Node
    right *Node
    data  int64
}
 
func (n *Node) insert(data int64) {
    if n == nil {
        return
    } else if data <= n.data {
        if n.left == nil {
            n.left = &Node{data: data, left: nil, right: nil}
        } else {
            n.left.insert(data)
        }
    } else {
        if n.right == nil {
            n.right = &Node{data: data, left: nil, right: nil}
        } else {
            n.right.insert(data)
        }
    }   
}
```

<!-- Структура не может содержать саму себя в качестве поля, для этого нужно использовать указатель. -->

---

# Литерал структуры

```go
type img struct {height, width int}

i := img{}
fmt.Println(i.height, i.width)		// 0 0
i = img{400, 300}					// позиционные значения
fmt.Println(i.height, i.width)		// 400 300
i = img{width: 300, height: 400}	// по названию полей
fmt.Println(i.height, i.width)		// 400 300
```

---

# Экспорт полей

```go
package account

type LocalUserAccount struct {
	Name, password string
}

var l := LocalUserAccount{Name: "anatoly", password: "12345678"} // все ок
```

Все поля доступны в рамках одного пакета

```go
package main

import "account"

func main(){
	l := account.LocalUserAccount{Name: "anatoly", password: "12345678"} // compile error: нет такого поля password
}
```

Экспортированные поля доступны в других пакетах

---

# Передача в функцию

```go
type employee struct {
	hourlyRate    int
	timeSpent     float32
	monthlyIncome float32
}

func monthlyIncome(e employee) employee {
	e.monthlyIncome = float32(e.hourlyRate) * e.timeSpent
	return e
}

// usage
e = monthlyIncome(e)
```

Передача структур (и не только) в функцию создает локальную копию значения.

---

# Передача по указателю

Для больших структур

```go
func monthlyIncome(e *employee) float32 {
	return float32(e.hourlyRate) * e.timeSpent
}
```

---

# monthlyIncome v2

```go
func monthlyIncome(e *employee) {
	e.monthlyIncome = float32(e.hourlyRate) * e.timeSpent
}
```

---

# monthlyIncome v3

```go
type employee struct {
	hourlyRate int
	timeSpent  float32
}

func (e employee) monthlyIncome() float32 {
	return float32(e.hourlyRate) * e.timeSpent
}
```

---

# Быстрый указатель при нициализации

```go
ptr := &img{500, 500}
```

## Можно использовать в выражении

```go
img := compress(&img{500, 500})
```

---
layout: section
---

# Сравнение структур

---
layout: fact
---

Если типы всех полей структуры являются сравниваемыми, то экземпляры этой структуры можно сравнивать.

---

# Пример

```go
type document struct {
	ID int
	Pages int
}

d1 := document{1, 100}
d2 := document{2, 50}

fmt.Println(d1 == d2) // false

```

---

Структура со сравниваемым полями является сравниваемой, поэтому ее можно использовать в качестве ключа map

```go
type article struct{
	ID int
	Content string
}

reads := make(map[article]int)
reads[article{1, "<h1>Hello, World!</h1>"}]++
```

---
layout: section
---

# Встраивание структур и анонимные поля

---

# Пример

```go
type user struct {
	ID                    int
	email, password       string
	lastLogin, registered time.Time
	isAdmin               bool
}

type profile struct {
	firstname string
	lastname  string
	gender    string
	age       int
	photo     string
	about     string
	user      user	// встраивание по имени
}

var p profile
p.user.registered = time.Now() // доступ
p.age = 18
```

---

# Анонимное поле

```go
type profile struct {
	firstname string
	lastname  string
	gender    string
	age       int
	photo     string
	about     string
	user	// тип без имени
}

var p profile
p.registered = time.Now() // p.user.registered = time.Now()
p.age = 18
```

<!-- Явная запись, показанная в комментариях, по-прежнему действительна, однако
название “анонимные поля” не совсем верно. Поле user имеет имя, но
это имя необязательно в выражениях с точкой. Мы можем опустить любое или все
анонимные поля при выборе их подполей. -->

---
layout: section
---

# Некоторые тонкости

---

# Литерал

```go
// registered – анонимное поле profile{user}
p := profile{
		"anatoly",
		"nikiforov",
		"male",
		29,
		"none",
		"author at mipt",,
		registered: time.Now()
		} // compile error: нет такого поля
```

## Fix

```go
p := profile{
		"anatoly",
		"nikiforov",
		"male",
		29,
		"none",
		"author at mipt",
		user{registered: time.Now()},
	}
```

---

# Экспорт

```go
type user struct {
	ID                    int
	Email, Password       string
	LastLogin, Registered time.Time
	IsAdmin               bool
}

// Экспортируем
type Profile struct {
	Firstname string
	Lastname  string
	Gender    string
	Age       int
	Photo     string
	About     string
	user      user	// приватное поле
}

// в другом пакете
var p Profile
p.user.ID = 1 // compile error: поля не существует, так как user приватное поле
```

<!-- Чтобы пофиксить, надо экспортировать поле user. -->

---
layout: section
---

# JSON

---

# Сериализация

```go
type Book struct {
	Title		string
	Year		int		`json:"published"`
	Author		string
	Language	string
	Pages 		int		`json:"pages,omitempty"`

}

var books = []Book{
		{"War and Peace", 1867, "Leo Tolstoy", "Russian", 1225},
		{"Moby-Dick", 1851, "Herman Melville", "English", 427},
		{"Don Quixote", 1605, "Miguel de Cervantes", "Spanish", 1077},
		// {"The Brothers Karamazov", 1880, "Fyodor Dostoyevsky", "Russian", 776},
		// {"Adventures of Huckleberry Finn", 1884, "Mark Twain", "English", 366},
		// {"The Count Of Monte Cristo", 1846, "Alexandre Dumas", "French", 894},
	}

s, _ := json.MarshalIndent(books, "", "    ")
fmt.Println(string(s))
```

---


## Вывод

```text
[
    {
        "Title": "War and Peace",
        "published": 1867,
        "Author": "Leo Tolstoy",
        "Language": "Russian",
        "pages": 1225
    },
    {
        "Title": "Moby-Dick",
        "published": 1851,
        "Author": "Herman Melville",
        "Language": "English",
        "pages": 427
    },
    {
        "Title": "Don Quixote",
        "published": 1605,
        "Author": "Miguel de Cervantes",
        "Language": "Spanish",
        "pages": 1077
    }
]
```

---
layout: end
---