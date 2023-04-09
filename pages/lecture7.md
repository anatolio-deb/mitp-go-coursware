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

```go{3-5|7|8-10|all}
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



---
layout: end
---