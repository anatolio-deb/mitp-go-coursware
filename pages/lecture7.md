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

# Интерфейсы как Контракты

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

## Конкретный пример: конвертер валют

---
layout: fact
---

Все валюты выражаются через условные единицы.

<!--
1. Можно выражать одни валюты через другие благодаря общему курсу.
2. Условная единица – универсальная единица оценивания других валют.
-->

---

# Задача

- $z$ – условная единица.
- $x$, $y$ - две валюты.
- ${x}'$, ${y}'$ – стоимость (количество) $x$, $y$ по отношению к $z$.
- ${x}''$, ${y}''$ – стоимость (количество) $z$ по отношению к $x$, $y$.

Выразить количество валюты $x$ в валюте $y$ и наоборот.

## Решение

1. $a = x * {x}''$ – сколько $z$ (условных единиц) в количестве валюты $x$?
2. $b = a * {y}'$ – сколько валюты $y$ в количестве $z$?

Где ${x}'' = \frac{1z}{x'}$

---
layout: section
---

# Реализация

---

В качестве валюты $x$ возьмем Российский Рубль, в качестве валюты $y$ возьмем Японский Йен, а в качестве условной единицы $z$ - Доллар США.

```go{1|2-5|6-11|all}
type USD float64
type Currency struct {
	Amount float64
	Rate   USD
}
type Rouble struct {
	Currency
}
type Yen struct {
	Currency
}
```

<!-- Почему usd не структура, а тип?
Потому что у условной единицы не может быть rate. Остается единственное поле amount, а структуру с одним полем лучше представить как тип.
 -->

---
layout: two-cols
---

```go{12-25}
type USD float64
type Currency struct {
	Amount float64
	Rate   USD
}
type Rouble struct {
	Currency
}
type Yen struct {
	Currency
}

func (c Currency) ToUSD() USD {
	if c.Amount == 0 {
		c.Amount++
	}
	return USD(c.Amount * float64((USD(1) / c.Rate)))
}
```

::right::

```go
func main() {
	y := Yen{Currency{Rate: USD(131.23)}}
	r := Rouble{Currency{Rate: USD(80.20)}}
	fmt.Println(y.ToUSD()) // 0.007620208793720948
	fmt.Println(r.ToUSD()) // 0.012468827930174562
}
```

И Рубль и Йены должны поддерживать выражение в Доллары, чтобы удовлетворять условию $x\to y\to x$.

---
layout: two-cols
---

<img src="Screenshot 2023-04-06 at 05.27.36.png"/>

::right::

<img src="Screenshot 2023-04-06 at 05.27.49.png"/>

---
layout: two-cols
---

# API

```go
func Convert(from Rouble, to Yen) float64 {
	return float64(from.ToUSD() * to.Rate)
}

func main() {
	r := Rouble{Currency{Rate: 80.19}}
	y := Yen{Currency{Rate: 130.88}}
	fmt.Println(Convert(r, y)) // 1.6321237061977802
}
```

<img src="Screenshot 2023-04-06 at 06.29.53.png">

::right::

# Что плохо?

<v-clicks>

- Функция Convert не универсальна
- Больше валют = больше функций = сложнее API
- Если есть две структуры с одинаковым методом, значит над ними может быть абстрактный тип (интерфейс)

</v-clicks>

---
layout: two-cols
---

```go{12|21-23|25-27|all}
type USD float64
type Currency struct {
	Amount float64
	Rate   USD
}
type Rouble struct {
	Currency
}
type Yen struct {
	Currency
}
type Exchangable interface{ ToUSD() USD }

func (c Currency) ToUSD() USD {
	if c.Amount == 0 {
		c.Amount++
	}
	return USD(c.Amount * float64((USD(1) / c.Rate)))
}

func (u USD) ToCurrency(c Currency) float64 {
    return float64(u * c.Rate)
    }

func Convert(from Exchangable, to Currency) float64 {
	return from.ToUSD().ToCurrency(to)
}
```

::right::

```go
func main() {
	y := Yen{Currency{Rate: 131.23}}
	r := Rouble{Currency{Rate: 80.20}}
	fmt.Println(Convert(y, r.Currency)) // 0.61114074525642
}
```

[https://go.dev/play/p/lWwbeZd-tpN](https://go.dev/play/p/lWwbeZd-tpN)

<!-- 
1. USD необязательно быть структурой
2. Exchangable – это контракт между функцией Convert и ее пользователями
3. По "контракту" функция Convert ожидает тип с методом ToUSD
4. Функции Convert без разницы как реализован конкретный ToUSD
5. API не зависит от количества валют
6. Rouble и Yen тоже Exchangable
-->


---
layout: end
---