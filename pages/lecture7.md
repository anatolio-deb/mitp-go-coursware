---
layout: intro
---

# Язык программирования Go
## Интерфейсы
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 7

---
layout: section
---

# Интерфейсы как контракты

---

# Абстрактный пример

```go{1-3|5-7|9-19|21-24||all}
func APIFunction(c contract) error { // эта функция для внешних пользователей
	return c.contractMethod()
}

type contract interface { // интерфейс определяет контракт между APIFunction и ее пользователями
	contractMethod() error
}

type concrete struct{} // Конкретный тип интерфейса contract

func (c concrete) contractMethod() error {
	return nil
}

type anotherConcrete struct{} // Конкретный тип интерфейса contract

func (a anotherConcrete) contractMethod() error {
	return nil
}

func main() {
	fmt.Println(APIFunction(concrete{}))        // nil
	fmt.Println(APIFunction(anotherConcrete{})) // nil
}
```

<!-- APIFunction работает с двумя различными типами. -->

---
layout: section
---

## Конкретный пример: стоимость недвижимости

---
layout: two-cols
---

```go{1|2|3|4,10-12|5-8,14-20|22-24|all}
const AveragePrice int = 5000
type Value interface{ Price() int }
type RealEstate struct { Rooms int }
type Condominium struct { RealEstate }
type SingleFamilyHome struct {
	RealEstate
	Garage bool
}

func (c Condominium) Price() int {
	return c.Rooms * 1000
}

func (s SingleFamilyHome) Price() int {
	p := s.Rooms * 1000
	if s.Garage {
		p += 1000
	}
	return p
}

func Valuate(v Value) int {
	return v.Price() * rand.Intn(AveragePrice)
}
```

::right::

```go
func main() {
	c := Condominium{RealEstate{Rooms: 3}}
	fmt.Println(c.Price()) // 3000
	s := SingleFamilyHome{
		RealEstate: RealEstate{
			Rooms: 3
			},
		Garage: true
		}
	fmt.Println(s.Price())  // 4000
	fmt.Println(Valuate(c)) // 14877000
	fmt.Println(Valuate(s)) // 6296000
}
```

<v-clicks>

- Метод Price – это контракт (договоренность) между конкретными структурами и Valuate.
- Все, что реализует метод Price, может быть оценено __независимо__ от алгоритма.
- Функции Valuate все равно, какой алгоритм реализует структура.

</v-clicks>

<!-- The idea: estimate a real estate market price
1. Average price among all types of real estate
2. Price() is a contract -->

---
layout: section
---

# Сигнатура контракта

---
layout: two-cols
---

```go{1|2|4|11-21|22-27|all}
const CAP int = 3000
const SFHAP int = 6000

type Value interface{ Price(factor int) int }
type RealEstate struct { Rooms int }
type Condominium struct { RealEstate }
type SingleFamilyHome struct {
	RealEstate
	Garage bool
}

func (c Condominium) Price(factor int) int {
	return (c.Rooms * 1000) * factor
}

func (s SingleFamilyHome) Price(factor int) int {
	p := s.Rooms * 1000
	if s.Garage {
		p += 1000
	}
	return p * factor
}

func Valuate(v Value, averagePrice int) int {
	factor := rand.Intn(averagePrice)
	return v.Price(factor)
}
```

::right::

```go
func main() {
	c := Condominium{RealEstate{Rooms: 3}}
	s := SingleFamilyHome{
		RealEstate: RealEstate{
			Rooms: 5,
		},
	}
	fmt.Println(Valuate(c, CAP)) // 6900000
	fmt.Println(Valuate(s, SFHAP)) // 16030000
}
```

<!--
1. Distinct average price for Condominiums
2. Distinct average price for Family Houses
3. New contract signature: factor affects the price
4. Methods now implements contract signature
5. API still the same, but implementation differs
-->

---
layout: section
---

# Типы интерфейсов

---
layout: two-cols
---

```go{1|3|4|5-8|9|11-13|15-17|19-21|all}
const AveragePrice int = 10000

type Value interface{ Price() int }
type Seller interface { Sell(v Value) }
type ValueSeller interface {
	Value
	Seller
}
type Agency struct { Income int }

func (a *Agency) Sell(v Value) {
	a.Income += Valuate(v)
}

func (a Agency) Price() int {
	return a.Income * 2
}

func Valuate(v Value) int {
	return v.Price() * rand.Intn(AveragePrice)
}
```

::right::

```go
func main() {
	s := SingleFamilyHome{
		RealEstate: RealEstate{
			Rooms: 5,
		},
	}
	a := Agency{}
	a.Sell(s) // продали дом
	fmt.Println(Valuate(a)) // 89389740000
}

```

<v-clicks>

- Встраивание интерфейсов удобно применять для того, чтобы не описывать множество методов больших интерфейсов.

</v-clicks>

<!-- 1. We have average price again.
2. Seller is a traditional definition of interfaces followed by stdlib style
3. ValueSeller is an example of interface embedding. It can be done by specifying methods implicitly too.
4. Agency is a Value Seller
5. Agency implements a Sell contract of Seller interface
6. Agency implements a Price contract of a Value interface 
7. We can Valuate a price of Agency too-->

---

# Другие способы встраивания

```go
type Value interface{ Price() int }
type Seller interface { Sell(v Value) }
type ValueSeller interface {
	Price() int
	Sell(v Value)
}
```

## Частичное встраивание

```go
type ValueSeller interface {
	Price() int
	Seller
}
```

---
layout: section
---

# Соответствие интерфейсу

---
layout: fact
---

Тип _соответствует_ интерфейсу если он обладает всеми методами интерфейса

---

# Правило

Выражение может быть присвоено интерфейсу только если его тип соответствует интерфейсу.

```go
type Seller interface { Sell(v Value) }
type Agent struct{ InterestIncome int }

func (a *Agent) Sell(v Value) {
	a.InterestIncome += Valuate(v) / 10
}

var v Value
v = SingleFamilyHome{} // ОК: у SingleFamilyHome есть метод Price
v = new(Agency)        // ОК: у Agency есть метод Price
v = Agent{}            // Error: у Agent нет метода Price

var vs ValueSeller
vs = &Agency{} // OK: у Agency есть методы Price и Sell
vs = Agent{}   // Error: у Agent нет метода Price
```

Работает даже когда тип присваиваемого значения – интерфейс.

```go
v = vs // OK: у Agency есть метод Price
vs = v // Error: у Value нет метода Sell
```

---
layout: section
---

# Напоминание

---
layout: fact
---

На каждом конкретном типе T могут быть определены как методы с ресивером типа T, так и методы с ресивером типа *T

---
layout: fact
---

Можно вызывать метод *T на аргументе типа T до тех пор, пока этот аргумент является _переменной_

<!-- Это синтаксический сахар: компилятор получает адрес самостоятельно -->

---


# Пример

```go{4-5|8|9-11|all}
type Seller interface{ Sell(v Value) }
type Agency struct{ Income int }

func (a *Agency) Sell(v Value) {
	a.Income += Valuate(v)
}

var _ = Agency{}.Sell(SingleFamilyHome{}) // Error: Sell требует ресивер *Agency
var a Agency
a.Sell(SingleFamilyHome{})
fmt.Println(a.Income) // 0
```

<v-clicks>

Поскольку метод Sell есть у *Agency, только *Agency соответствует интерфейсу Seller

```go
var _ Seller = &a // OK
var _ Seller = a // Error: у Agency нет метода Sell
```

</v-clicks>

<!--
1. Метод Sell принимает указатель на ресивер.
2. Компилятор не может вызвать метод на переменной без адреса.
3. Но его можно вызвать на переменной.
-->

---

Интерфейс оборачивает и скрывает конкретный тип и значение, которое он содержит. 

Вызывать можно только методы, которые раскрывает интерфейс, даже если у конкретного типа есть другие методы.

```go
var a = Agency{}
a.Sell(SingleFamilyHome{}) // OK: у *ValueSeller есть метод Sell 
a.Price() // OK: у *ValueSeller есть метод Price 

var s Seller
s = &Agency{}
s.Sell(SingleFamilyHome{}) // OK: у Seller есть метод Sell 
s.Price() // Error: у Seller нет метода Price
```

---
layout: section
---

# Пустой интерфейс

---
layout: fact
---

Чем больше методов в интерфейсе, тем больше требований к типам, которые его реализуют.

---

# Пустой интерфейс не требует от типов ничего

Поэтому пустому интерфейсу можно присвоить любое значение

```go
var any interface{}
any = false
any = 24.0
any = "hello world"
any = []int{1,2,3,4,5}
any[0]++ // Error: нет прямого доступа к значению в пустом интерфейсе потому, что у него нет методов
```

# Usage из стандартной библиотеки

[https://pkg.go.dev/fmt#Println](https://pkg.go.dev/fmt#Println)

```go
func Println(a ...any) (n int, err error)
```

[https://pkg.go.dev/fmt#Errorf](https://pkg.go.dev/fmt#Errorf)

```go
func Errorf(format string, a ...any) error
```

---
layout: section
---

# Значение интерфейса

---

# Идея

Значение интерфейса составляют две компоненты:

- конкретный тип (динамический тип)
- значение этого типа (динамическое значение)

---
layout: fact
---

Компонента типа интерфейса представлена _дескриптором типа_, то есть тем, значением, которое описывает тип (его имя, методы и т.п).

---

# Пример

```go
var s Seller
s = &Agent{}
s.Sell(SingleFamilyHome{})
s = new(Agency)
s = nil
```

<!--  1. У Seller есть метод Sell
2. У Agent и Agency есть методы Sell, поэтому их можно присвоить типу Seller. -->

---

# Нулевое значение интерфейса

```go
var s Seller
s = nil
```

<img src="/public/Untitled drawing (11).png" />

Определение значения интерфейса как нулевого или отличного от нулевого определяется по его динамическому типу.

---

# Указатель на тип как значение интерфейса

```go
s = &Agent{}
```

<img src="/public/Untitled drawing (16).png"/>

Присваивание выше – это неявное преобразование типа:

```go
s = Seller(&Agent{})
```

- динамический тип интерфейса принимает дескриптор типа указателя *Agent
- динамическое значение интерфейса принимает копию указателя на Agent

---

## Как происходит вызов метода типа на интерфейсе?

```go
s.Sell(SingleFamilyHome{})
```

Вызов метода Sell на значении интерфейса, содержащего указатель *Agent, влечет вызов метода (*Agent).Sell.

Компилятор использует динамическую отправку (dynamic dispatch) чтобы сгенерировать код, возвращающий адрес метода Sell из дескриптора типа, затем делает непрямой вызов по этому адресу. В качестве ресивера тогда выступает копия динамического значения интерфейса – Agent. Эффект такой, как если бы мы делали прямой вызов (в данном случае брали бы адрес ресивера явно):

```go
(&Agent{}).Sell(SingleFamilyHome{})
```

_Здесь указан непрямой вызов, так как методу Agent.Sell нужен указатель на ресивер._

---

Для типов, которые имеют прямой доступ к ресиверу, это выглядит так:

```go{7}
type Seller interface{ Sell(v Value) int }
type Agent struct{}
func (a Agent) Sell(v Value) int {
	return Valuate(v) / 10
}

Agent{}.Sell(SingleFamilyHome{})
```

---

# Тип как значение интерфейса

```go
var s Value
s = SingleFamilyHome{RealEstate: RealEstate{Rooms:4}}
```

<img src="/public/Untitled drawing (17).png"/>

---
layout: fact
---

Два интерфейса равны, если у них один динамический тип, а их динамические значения равны согласно операции == определенной на этом типе. 

---

# Интерфейсы можно сравнивать не всегда

```go
var x interface{} = func() {}
fmt.Println(x == x) // panic: runtime error: comparing uncomparable type func()
```

Сравнивайте интерфейсы только, когда вы уверены, что их динамические значение содержат сравниваемые типы.

<!-- Их нельзя сравнивать, если их динамические значения содержат не сравниваемый тип. -->

---
layout: section
---

# Утверждение типов

---
layout: fact
---

Утверждение типа (type assertion) – это операция вида x.(T) на значении интерфейса, где x – выражение типа интерфейса, T – тип, называемый «утверждаемым» типом. 

---

# Утверждение конкретного типа

Проверяет, что динамический тип интерфейса x соответствует типу T.

```go
var s Seller
s = &Agent{}
a := s.(*Agent) // возвращает динамическое значение x типа *Agent
fmt.Printf("%T\n", a) // *Agent
b := s.(*Agency)      // panic: interface conversion: main.Seller is *main.Agent, not *main.Agency
fmt.Printf("%T\n", b)
```

---

# Утверждение типа интерфейса

Проверяет, что динамический тип x соответствует T.

```go
var s Seller
s = &Agency{}
vs := s.(ValueSeller) // возвращает интерфейс с типом ValueSeller
fmt.Printf("%T\n", vs) // *main.Agency
s = new(Agent)
vs = s.(ValueSeller) // panic: interface conversion: *main.Agent is not main.ValueSeller: missing method Price
```

---

# Утверждение типа без паники

```go
var s Seller = &Agent{}
agent, ok := s.(*Agent) // ok, a == Agent
agency, ok = s.(*Agency) // !ok, a == nil
```

# Usage

```go
if a, ok := s.(*Agent); ok {
	a.Sell(SingleFamilyHome{})
}
```

---

# Типы, switch и пустой интерфейс

```go
func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}
```

---

# Дополнительно

- [Dynamic dispatch](https://en.wikipedia.org/wiki/Dynamic_dispatch#:~:text=In%20computer%20science%2C%20dynamic%20dispatch,(OOP)%20languages%20and%20systems.)
- [https://github.com/teh-cmc/go-internals](https://github.com/teh-cmc/go-internals/blob/master/chapter2_interfaces/README.md)

---
layout: end
---