---
layout: intro
---

# Язык программирования Go
## Функции
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 5

---

# Объявление

```text
func имя(параметры) (результаты) {
    тело
}
```

---

# Именованные результаты

```go
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}
```

- return без аргументов возвращает значения имен в результатах; известен как "голый" return.
- Лучше использовать только в коротких функциях; в длинных ухудшает читаемость.

---

# Объединение типов параметров

```go
func old(a int, b int, x float64, y float64){
    /* ... */
}

func new(a, b int, x, y float64){
    /* ... */
}
```

---

# Сигнатуры

```go
func Percent(percent int, all int) float64 {
	return ((float64(all) * float64(percent)) / float64(100))
}

func PercentV2(percent, all int) float64 {
	return ((float64(all) * float64(percent)) / float64(100))
}

func PercentV3(percent, all int) (amount float64) {
	amount = ((float64(all) * float64(percent)) / float64(100))
	return
}

fmt.Printf("%T\n", Percent)     // func(int, int) float64
fmt.Printf("%T\n", PercentV2)   // func(int, int) float64
fmt.Printf("%T\n", PercentV3)   // func(int, int) float64
```

- Сигнатура – это тип функции
- Имена параметров/результатов не влияет на сигнатуру (тип) функции

---
layout: section
---

# Вариативные функции

---

# Пример

В теле функции Concat множество аргументов принимает вид []string.

```go
func Concat(strings ...string) string {
	n := ""

	for _, v := range strings {
		n += v
	}

	return n
}

func main() {
    fmt.Println(Concat()) // ""
    fmt.Println(Concat("h", "e", "l", "l", "o", " ", "world"))  // hello world
}
```

- Принимает разное количество аргументов одного типа
- Безопасно вызывать без аргументов 

--- 

# Передача среза в вариативную функцию

Многоточие – оператор распаковки среза.

```go
values := ["h", "e", "l", "l", "o"]
fmt.Println(Concat(values...)) // hello
```

---

# Тип вариативной функции

```go
func a(...int) {}
func b([]int) {}

fmt.Printf("%T\n", a)   // func(...int)
fmt.Printf("%T\n", b)   // func([]int)
fmt.Println(reflect.TypeOf(a) == reflect.TypeOf(b)) // false
```

---
layout: fact
---

Нет параметров по умолчанию.

Что делать?

---
layout: section
---

## Шаблон «Функциональные опции»

---

# Мы пишем API клиент

```go
// Создает и возвращает API клиент
func NewAPIclient(token string, debug bool, timeout time.Duration, maxRetries int) *APIclient
```

## Мы хотим

- token – обязательный параметр
- debug, timeout, maxRetries – необязательные параметры со значениями по-умолчанию

### User-friendly way

```go
const token string = "nd/APo7p=UZMwwD61hR0Fm=Rwa4ww7ctJpOSpp5fiIua?QlUCiSGI!2HoMOX39sZ"
apiClient := NewAPIclient(token)
```

---

# Способ №1: множество функций

```go
// Возвращает API клиент с параметрами по-умолчанию
func NewAPIclient(token string) *APIclient

// Возвращает API клиент, который логирует информацию в stdout 
func NewAPIclientWithDebug(token string, debug bool) *APIclient

// Возвращает API клиент, который прерывает соединение с сервером, если он не отвечает
func NewAPIclientWithTimeout(token string, timeout time.Duration) *APIclient

// Возвращает API клиент, который прерывает соединение с сервером, если он не отвечает, и пробует соединиться снова
func NewRetriableAPIclientWithTimeout(token string, timeout time.Duration, maxRetries int) *APIclient

// Возвращает API клиент, который логирует информацию в stdout, прерывает соединение с сервером, если он не отвечает,
// и пробует соединиться снова
func NewRetriableAPIclientWithDebugAndTimeout(token string,  debug bool, timeout time.Duration, maxRetries int) *APIclient
```

## Недостатки

- Не user-friendly: ищи в библиотеке нужную функцию
- Зависимость количества функций от полей структуры (APIclient) 

---

# Способ №2: Config

```go
// Конфиг используется для настройки API клиента
type Config struct {
    // Логирует информацию в stdout
    Debug bool
    // Timeout устанавливает промежуток времени,
    // после которого клиент закроет соединение с API сервером,
    // если он не отвечает
    Timeout time.Duration
    // MaxRetries устанавливает максимальное количество
    // повторных попыток соединения с API сервером
    MaxRetries int
}

func NewAPIclient(token string, config Config) *APIclient
```

---

# Достоинства

- Конфиг может дополняться новыми полями, но публичный API создания клиента не изменится
- Массивная документация множества функций перемещается в аккуратную документацию структуры

# Недостатки

- Необходимость использовать нулевые значения,если нужно поведение по-умолчанию
- Невозможность отличить явное нулевое значение от нулевого значения поля

---
layout: section
---

# Проблема нулевых значений

---

# Новые требования к API клиенту

MaxRetries == 3 по-умолчанию 

```go
func NewAPIclient(token string, config Config) *APIclient {
	if config.MaxRetries == 0 {
		return &APIclient{Token: token, MaxRetries: 3}
	}
	return &APIclient{Token: token, MaxRetries: config.MaxRetries}
}
```

Если пользователь захочет MaxRetries == 0, то он все равно получит 3, так как невозможно отличить явное нулевое значение от нулевого значения поля.

---

# Еще проблема

```go
func NewAPIclient(token string, config Config) *APIclient

func main(){
    const token string = "nd/APo7p=UZMwwD61hR0Fm=Rwa4ww7ctJpOSpp5fiIua?QlUCiSGI!2HoMOX39sZ"
    apiClient := NewAPIclient(token, Config{}) // зачем пустое значение?
}
```

Даже если клиент хочет поведение по-умолчанию без какой-либо конфигурации, ему все равно нужно передавать второй аргумент чтобы просто удовлетворить сигнатуру функции.

---

# Возможно поможет указатель?

```go
func NewAPIclient(token string, config *Config) *APIclient {
	if config == nil {
		return &APIclient{Token: token, MaxRetries: 3}
	}
	return &APIclient{Token: token, MaxRetries: config.MaxRetries}
}
```

# Достоинства

Обработка нулевых значений

```go
const token string = "nd/APo7p=UZMwwD61hR0Fm=Rwa4ww7ctJpOSpp5fiIua?QlUCiSGI!2HoMOX39sZ"
apiClient := NewAPIclient(token, nil)   // клиент по умолчанию
fmt.Println(apiClient.MaxRetries)   // 3

config := Config{MaxRetries: 0}
apiClient = NewAPIclient(token, &config)
fmt.Println(apiClient.MaxRetries)   // 0
```

---

# Недостатки

- Все равно надо передавать nil вторым аргументом
- Пользователь и клиент разделяют один конфиг

```go
config.MaxRetries += 1 // Что произойдет?
```

---

# Вариативная конфигурация

```go
func NewAPIclient(token string, config ...Config) *APIclient

func main() {
    const token string = "nd/APo7p=UZMwwD61hR0Fm=Rwa4ww7ctJpOSpp5fiIua?QlUCiSGI!2HoMOX39sZ"
    apiClient := NewAPIclient(token)    // клиент по-умолчанию

    // Timeout после 1 минуты, максимум 7 попыток
    apiClient = NewAPIclient(token, Config{
        Timeout: 60 * time.Second,
        MaxRetries: 7
        })
}
```

## Достоинства

- Не нужно передавать nil или пустой конфиг
- Поведение по-умолчанию вызывается простым способом

---

# Недостатки

- Можно передать множество конфигов (вариативность)
- Придется менять реализацию под этот случай

---
layout: fact
---

Можно ли сохранить вариативную сигнатуру функции и улучшить выразительность параметров?

---

# Функциональные опции

```go
func NewAPIclient(token string, options ...func(*APIclient)) *APIclient {}

func main() {
    apiClient := NewAPIclient(token) // по-умолчанию

    timeout := func(c *APIclient) {
        c.Timeout = 60 * time.Second
    }

    retries := func(c *APIclient) {
        c.MaxRetries = 1
    }

    debug := func(c *APIclient) {
        c.Debug = true
    }

    // клиент с дебагом, минутным таймаутом и одной попыткой
    apiClient = NewAPIclient(token, timeout, retries, debug)
}
```

<!-- Реализация NewAPIclient пустая чтобы поместился весь код. В реализации мы просто перебираем срез опций в цикле, вызываем функции и возвращаем клиент. -->

---

# Достоинства

- Шаблон позволяет проектировать красивые API
- Простейшая реализация поведения по-умолчанию
- Читаемые и значимые параметры
- Прямой контроль над инициализацией сложных значений

---

# Недостатки

???


---
layout: section
---

## Множество возвращаемых значений

---

# Пример

```go
func saveUser(u *User) (ID string, err error) {} 

func validateEmail(email string) (string, bool) {
    var ok bool

	if !strings.Contains("@", email) {
		ok = false
	}

	return email, ok
}

func HandleUser(u *User) (string, error) {
    email, ok := validateEmail(u.Email)

    if !ok {
        return email, errors.New("validation error")
    }

    return saveUser(u)
}
```

<!-- SaveUser и HandleUser имеют одинаковые возвращаемые значения, поэтому их можно совместить. Этот код можно зарефакторить с помощью типа Email ее метода validate. validateEmail – типичный шаблон. -->

---
layout: section
---

# Обработка ошибок

---

# Пример №1

```go
f, err := os.Open("filename")

if err != nil {
    return nil, err
}
```

<!-- Не говорить много, это просто типичный шаблон -->

---

# Пример №2

```go
fname := "README.md"
f, err := os.Open(fname)

if err != nil {
    return nil, fmt.Errorf("open file %s: %v", fname, err)
}
```

---

# Пример №3

<!-- TODO: replace with own example -->

```go
// WaitForServer attempts to contact the server of a URL.
// It tries for one minute using exponential back-off.
// It reports an error if all attempts fail.
func WaitForServer(url string) error {
    const timeout = 1 * time.Minute
    deadline := time.Now().Add(timeout)
    for tries := 0; time.Now().Before(deadline); tries++ {
        _, err := http.Head(url)
        if err == nil {
            return nil // success
        }
        log.Printf("server not responding (%s); retrying...", err)
        time.Sleep(time.Second << uint(tries)) // exponential back-off
    }
    return fmt.Errorf("server %s failed to respond after %s", url, timeout)
}
```
---

# Обработка №1

<!-- TODO: replace with own example -->

```go
// (In function main.)
if err := WaitForServer(url); err != nil {
    fmt.Fprintf(os.Stderr, "Site is down: %v\n", err)
    os.Exit(1)
}
```

<!-- Программа завершает свою работу возвращая код ошибки. -->

---

# Обработка №2

<!-- TODO: replace with own example -->

```go
if err := WaitForServer(url); err != nil {
    log.Fatalf("Site is down: %v\n", err)
}
```

## Вывод

```text
2006/01/02 15:04:05 Site is down: no such domain: bad.gopl.io
```

## Тюнинг для клиентов

```go
log.SetPrefix("timeout: ")
log.SetFlags(0)
```

<!-- Fatalf завершает работу программы с ошибкой, но выводит лог. Используется на серверах. Упомянуть уровни лога. Тюнинг убирает дату и время из лога, можно настроить под себя. -->


---

# Обработка №4

<a href="https://github.com/GlenDC/go-external-ip">https://github.com/GlenDC/go-external-ip</a>

```go
ip, err := consensus.ExternalIP()

if err != nil {
    log.Printf("lookup failed: %v; DNS/networking issue", err)
}
```

 <!-- Не прерывает выполнения, а только выводит лог -->

---

# Обработка № 5


```go
ip, err := consensus.ExternalIP()

if err != nil {
    log.Fprintf(os.Stderr, "lookup failed: %v; DNS/networking issue\n", err)
}
```

<!-- Направить в стандартный поток ошибок -->

---
layout: section
---

# Значения функций

---
layout: fact
---

Функции в Go – это первоклассные значения (функции высшего порядка).

<!-- Значит, у них есть тип, их можно присваивать переменным и передавать в качестве аргументов. -->

---

# Пример

```go
func isEven(n int) bool { return n % 2 == 0 }
func isOdd(n int) bool { return n % 2 > 0 }
func remainder(n int) int { return n % 2 }

f := isEven
fmt.Println(f(2)) // true

f = isOdd
fmt.Println(f(3)) // true

f = remainder // compile error: can't assign f(int) bool to f(int) int
```

---

# Нулевое значение

```go
var f func(int) int
f(2) //panic: вызов nil
```

<!-- Нулевое значение функции – nil, nil нельзя вызвать. -->


---

# Сравнения

```go
var f func(int) int
if f != nil {
    f(2)
}
```

- Функции можно сравнить c nil
- Функции нельзя сравнивать между собой
- Функции не могут быть ключами в map

---

# Функции в качестве аргументов

Позволяют менять поведение

```go
trim := func(r rune) rune {
		if unicode.IsSpace(r) {
			return -1
		}
		return r
	}
fmt.Println(strings.Map(trim, " hello world ")) // helloworld
```

---
layout: section
---

# Анонимные функции

---

# Пример

```go
strings.Map(func(r rune) rune {
		if unicode.IsSpace(r) {
			return -1
		}
		return r
	}, " hello world ")
```

---

# Область видимости

```go
func inc() func() int {
	var x int
	return func() int {
		x++
		return x
	}
}

func main() {
	f := inc()
	fmt.Println(f()) // 1
    fmt.Println(f()) // 2
    fmt.Println(f()) // 3
}
```

Анонимная функция имеет доступ ко всему лексическому окружению внешней функции.

---
layout: section
---

# defer

---
layout: fact
---

defer – последнее действие в теле функции, которое выполняется независимо от результата работы функции

---

# Пример №1

```go
resp, err := http.Get("https://example.com")
if err != nil {
    return err
}
defer resp.Body.Close()
```

# Пример №2

```go
f, err := os.Open("README.md")
if err != nil {
    return err
}
defer f.Close()
```

---
layout: section
---

# Обработка ошибок из defer

---

# Пример

```go
func cleanup() error {
        fmt.Println("Running cleanup...")
        return fmt.Errorf("error on cleanup")
}

func getMessage() (string, error) {
        defer cleanup()
        return "hello world", nil
}

func main() {
        message, err := getMessage()
        if err != nil {
                fmt.Printf("Error getting message: %v\n", err)
        } else {
                fmt.Printf("Success. Message: '%s'\n", message)
        }
}
```

## Вывод (нет ошибки из cleanup)

```text
Running cleanup...
Success. Message: 'hello world'
```

---

# Fix

```go
func getMessage() (msg string, err error) {
        defer func() {
                err = cleanup()
        }()
        return "hello world", err
}
```

## Вывод

```text
Running cleanup...
Error getting message: error on cleanup
```

---
layout: section
---

# panic

---

# Пример

```go
var x []int
fmt.Println(x[0])
```

## Вывод

```text
panic: runtime error: index out of range [0] with length 0

goroutine 1 [running]:
main.main()
	/tmp/sandbox2156457809/prog.go:9 +0x18

Program exited.
```

- panic завершает обычное исполнение 
- После паники исполняются defer
- Программа падает с логом
- Лог содержит сообщение ошибки, которую принимает panic
- Лог содержит трассировку стека

---

# Вызов паники

```go
func saveUser(u *User) (ID string, err error)

func validateEmail(email string) (string, bool)

func HandleUser(u *User) (string, error) {
	_, ok := validateEmail(u.Email)

	if !ok {
		panic("validation error") // не обязательно
	}

	return saveUser(u)
}

func main() {
	HandleUser(&User{Email: "a"})
}
```

---

## Вывод

```text
panic: validation error

goroutine 1 [running]:
main.HandleUser(0x0?)
	/tmp/sandbox1300934364/prog.go:27 +0x45
main.main()
	/tmp/sandbox1300934364/prog.go:34 +0x39

Program exited.
```


---
layout: section
---

# recover

---

# Пример

Если в паникующей функции есть recover в defer, то паника прерывается, а recover возвращает ошибку из паники.

```go
func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered. Error:\n", r)
		}
	}()
	panic("panic!")

	fmt.Println("After panic()") // never occures
}
```

## Вывод

```text
Recovered. Error:
 panic

Program exited.
```


---
layout: end
---