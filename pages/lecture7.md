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

```go
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

# Постановка задачи

- $z$ – условная единица.
- $x$, $y$ - две валюты.
- ${x}'$, ${y}'$ – стоимость (количество) $x$, $y$ по отношению к $z$.
-  ${x}''$, ${y}''$ – стоимость (количество) $z$ по отношению к $x$, $y$.

Выразить количество валюты $x$ в валюте $y$ и наоборот.

## Алгоритм

1. $a = x * {x}''$ – сколько $z$ (условных единиц) в количестве валюты $x$?
2. $b = a * {y}'$ – сколько валюты $y$ в количестве $z$?

---
layout: section
---

# Реализация

---

# Попытка №1

В качестве валюты $x$ возьмем Российский Рубль, в качестве валюты $y$ возьмем Японский Йен, а в качестве условной единицы $z$ - Доллар США.

```go
type usd struct { amount float64 }
type rouble struct { amount float64 }
type yen struct { amount float64 }
```

# Что плохо?

<v-clicks>

Если у структуры одно поле, то ее можно заменить типом.

</v-clicks>

---

# Попытка №2

И Рубль и Йены должны поддерживать выражение в Доллары, чтобы удовлетворять условию $x\to y\to x$.

```go
type usd float64
type rouble float64
type yen float64

func (r rouble) toUSD() usd { return usd(r * 0.012) }
func (y yen) toUSD() usd { return usd(y * 0.0076) }
```

## Что плохо?

<v-clicks>

- Нужны ли типы с одинаковыми нижележащими типами?
- Почему не использовать просто float64?

</v-clicks>

---

# Попытка №3

```go
// Конвертирует количество любой валюты в условные единицы.
// usd - стоимость (количество) условных единиц по отношению к amount
func toUSD(amount float64, usd float64) float64 {
	return amount * usd
}

func main() {
	usdFromRouble := toUSD(80, 0.012)
	fmt.Println(usdFromRouble) // 0.96
	usdFromYen := toUSD(130, 0.0076)
	fmt.Println(usdFromYen) // 0.988
}
```

# Что плохо?

<v-clicks>

Плохой API, непонятные параметры, необходимость документации.

</v-clicks>

---
layout: two-cols
---

# Попытка №4

```go
type currency struct {
	amount float64 // количество валюты
	rate   float64 // стоимость одной условной единицы в валюте
}
type rouble struct{ currency }
type yen struct{ currency }

func (r rouble) toUSD() float64 { return r.amount * 0.012 }

func (y yen) toUSD() float64 { return y.amount * 0.0076 }

func convert(from rouble, to yen) float64 {
	return from.toUSD() * to.rate
}

func main() {
	r := rouble{currency{1, 80.19}}
	y := yen{currency{rate: 130.88}}
	fmt.Println(convert(r, y)) // 1.57056
}
```

::right::

# Что плохо?

<v-clicks>

- Функция convert не универсальна
- Больше валют = больше функций = сложнее API
- Если есть две структуры с одинаковым методом, значит над ними может быть абстрактный тип (интерфейс)

</v-clicks>

---

# Попытка №5

```go
type currency struct {
	amount float64
	rate   float64
}
type rouble struct{ currency }
type yen struct{ currency }
type convertable interface{ toUSD() usd }
type usd float64

func (u usd) toCurrency(c currency) float64 { return float64(u) * c.rate }

func (r rouble) toUSD() usd { return usd(r.amount * 0.012) }

func (y yen) toUSD() usd { return usd(y.amount * 0.0076) }

func convert(from convertable, to currency) float64 {
	return from.toUSD().toCurrency(to)
}

func main() {
	fmt.Println(convert(yen{currency{amount: 1}}, rouble{currency{rate: 80.20}}.currency)) // 0.6095200000000001
}
```

<!-- 
1. usd необязательно быть структурой
2. convertable – это контракт между функцией convert и ее пользователями
3. По "контракту функция convert ожидает тип с методом toUSD
4. Функции convert без разницы как реализован конкретный toUSD
5. API не зависит от количества валют
-->

---

## Вывод

```text
0.6095200000000001
```

---

<img src="Screenshot 2023-04-06 at 03.30.49.png"/>

---
layout: fact
---

[https://go.dev/play/p/8ae38ReQzuc](https://go.dev/play/p/8ae38ReQzuc)

---
layout: end
---