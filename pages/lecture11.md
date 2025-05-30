---
layout: intro
---

# Язык программирования Go
## Тестирование
### Анатолий Никифоров, OTUS, 2025
#### Лекция 11

<!-- В этой лекции мы не будем касаться тестирования одной функции. Вы можете посмотреть тесты в репозитории домашних заданий. Поговорим о других известных техниках тестирования. -->

---

# Методология тестирования

- Методы тестирования особенных случаев
- Техники написания хороших тестов
- Больше чем `assert(func() == expected)`

---

# Тестируемый код

- Как писать код, который легко тестировать.
- Писать тестируемый код также важно, как и писать хорошие тесты.
- Если код невозможно потестить, возможно он написан таким образом.
- Рефакторинг существующего кода под тесты может быть больным, но он того стоит.

---
layout: section
---

# Подтесты (subtests)

---

# Пример

```go
func TestTime(t *testing.T) {
    testCases := []struct {
        gmt  string
        loc  string
        want string
    }{
        {"12:31", "Europe/Zuri", "13:31"},
        {"12:31", "America/New_York", "7:31"},
        {"08:08", "Australia/Sydney", "18:08"},
    }
    for _, tc := range testCases {
        t.Run(fmt.Sprintf("%s in %s", tc.gmt, tc.loc), func(t *testing.T) {
            loc, err := time.LoadLocation(tc.loc)
            if err != nil {
                t.Fatal("could not load location")
            }
            gmt, _ := time.Parse("15:04", tc.gmt)
            if got := gmt.In(loc).Format("15:04"); got != tc.want {
                t.Errorf("got %s; want %s", got, tc.want)
            }
        })
    }
}
```

---

# Запустить один из подтестов

```text
$ go test -run=TestTime/"in Europe"
```

---

# Подтесты

- Встроены в Go
- Можно запустить отдельный подтест
- Могут быть вложенными

---
layout: section
---

## Таблично-ориентированные тесты

---

# Пример

```go
func TestTime(t *testing.T) {
    testCases := []struct {
        gmt  string
        loc  string
        want string
    }{
        {"12:31", "Europe/Zuri", "13:31"},     // incorrect location name
        {"12:31", "America/New_York", "7:31"}, // should be 07:31
        {"08:08", "Australia/Sydney", "18:08"},
    }
    for _, tc := range testCases {
        loc, err := time.LoadLocation(tc.loc)
        if err != nil {
            t.Fatalf("could not load location %q", tc.loc)
        }
        gmt, _ := time.Parse("15:04", tc.gmt)
        if got := gmt.In(loc).Format("15:04"); got != tc.want {
            t.Errorf("In(%s, %s) = %s; want %s", tc.gmt, tc.loc, got, tc.want)
        }
    }
}
```

---

## Таблично-ориентированные тесты

- Легко добавлять новые условия
- Упрощают сценарии исчерпывающего тестированя
- Упрощают воспроизводство багов

---

# Наименования тестов

```go
func TestAdd(t *testing.T) {
    cases := []struct{
        Name string
        A, B, Expected int
    }{
        {"foo", 1, 1, 2},
        {"bar", 1, -1, 0},
    }

    for k, tc := range cases {
        t.Run(tc.Name, func(t *testing.T){
            ...
        })
    }
}
```

---
layout: section
---

# Фикстуры

---

# Пример

```go
func TestAdd(t *testing.T) {
    data := filepath.Join("test-fixtures", "add_data.json")
    
    // Работа с данными
}
```

---

# Фикстуры

- go test устанавливает pwd в директорию пакета
- Используйте относительный путь "test-fixstures" в качестве места для хранения тестовых данных
- Полезно для загрузки конфигов, данных моделей, бинарных данных и т.д.

---
layout: section
---

## Эталонные файлы и флаги тестирования

---

# Пример

```go
var update = flag.Bool("update", "update golden files")

func TestAdd(t *testing.T) {
    // .. таблица (возможно!)

    for _, tc := range cases {
        actual := doSomething(tc)
        golden := filepath.Join("test-fixtures", tc.Name+".golden")

        if *update{
            ioutil.WriteFile(golden, actual, 0644)
        }

        excpected, _ := ioutil.ReadFile(golden)

        if !bytes.Equal(actual, excpected) {
            // FAIL!
        }
    }
}
```

---

# Обычный запуск

```text
$ go test
...
```

# Запуск с флагом

```text
$ go test -update
...
```

---

# Эталонные файлы

- Помогают тестировать сложный вывод без необходимости писать код руками
- Можно посмотреть на генерируемые данные и проверить корректность
- Масштабируемый способ тестирования сложных структур (напишите метод String())

---
layout: section
---

# Глобальное состояние

---

# Глобальное состояние

- Избегайте глобального состояния
- Вместо глобального состояния попробуйте сделать из глобальной сущности опцию конфигурации со значением по-умолчанию в глобальном состоянии, позволяя тестам изменяит ее.
- Если необходимо, сделайте шлобальное состояние изменяемой переменной.

---

# Пример

```go
// Не хорошо само по себе
const port = 3000

// Лучше
var port = 3000

// Лучше всего
const defaultPort = 3000

type ServerOpts {
    Port int // Присвойте defaultPort где-нибудь
}
```

---

# Функции-помощники

```go
func testTempFile(t *testing.T) string {
    t.Helper()

    tf, err := ioutil.TempFile("", "test")

    if err != nil{
        t.Fatalf("err: %s", err)
    }
    tf.Colse()

    return tf.Name()
}
```

---

# Функции-помощники

- _Никогда_ не возварщают ошибку. 
- Использование функций-помощников улучшается когда они не возвращают ошибки, так как нет необходимости проверять ошибки.
- Улучшают читаемость тестов, отстроняя шаблонный код
- Вызывайте `t.Helper()` для более чистого вывода.

---

# Пример 1

```go
func testTempFile(t *testing.T) (string, func()) {
    t.Helper()

    tf, err := ioutil.TempFile("", "test")
    
    if err != nil {
        t.Fatalf("err: %s", err)
    }
    tf.Close()

    return tf.Name(), func(){ os.Remove(tf.Name()) }
}

func TestThing(t *testing.T) {
    tf, tfclose := testTempFile(t)
    defer tfclose()
}

```

---

# Пример 2

```go
func testChdir(t *testing.T, dir string) func() {
    t.Helper()

    old, err := os.Getwd()

    if err != nil {
        t.Fatalf("err: %s", err)
    }

    if err := os.Chdir(dir); err != nil {
        t.Fatalf("err: %s", err)
    }

    return func() { os.Chdir(old) }
}

func TestThing(t *testing.T) {
    defer testChdir(t, "/other")()
}
```

---

# Функции-помощники

- Возврат функции – это элегантный способ скрыть очистки
- Функция может иметь доступ к *testing.T чтобы влиять на ход тестирования
- Пример: testChdir занимает как минимум 10 строк, мы не пишем их вовсех тестах, а используем функцию помощник.

---
layout: section
---

# Пакеты и функции

---

# Пакеты и функции

- Разбивайте функциональность на пакеты и функции разумно
- Не злоупотребляйте этим.
- Правильное разбиение поможет писать тесты и одновременно улучшит организацию кода. Злоупотребление осложнит тестирование и читаемость.

---

# Пакеты и функции

- Можно тестировать только экспортированные функции, экспортированный API.
- Если у функция очень сложная, то желательно покрыть ее тестом.
- Воспринимайте неэкспортированные функции как детали реализации. Если вы получаете нужное поведение API, значит они работают правильно.
- Это не означает, что достаточно тестировать только внешний API.

---
layout: section
---

# Сети

---

- Тестируете сеть? Делайте реальное сетевое подключение.
- Не заглушайте `net.Conn` – это бесмыссленно.

---

# Пример

```go
func Test(t *testing.T) (client, server net.Conn) {
    t.Helper()

    ln, err := net.Listen("tcp", "127.0.0.1:0")

    var server net.Conn

    go func(){
        defer ln.Close()
        server, err = ln.Accept()
    }()

    client, err := net.Dial("tcp", ln.Addr().String())
    return client, server
}
```

---

# Сети

- Легко делать много соединений
- Лего тестировать любой протокол
- Легко возвращать listener
- Легко тестировать IPv6

---
layout: section
---

# Настраиваемость

---

# Настраиваемость

- Ненастраиваемое поведение часто приводит к сложности тестирования
    - Пример: порты, таймауты, пути
- Заполняйте структуры параметрами чтобы тесты могли их подстроить под себя
- Можно делать эту конфигурацию внутренней, только для тестов.

---

# Пример

```go
// Делайте так, даже если кэш и порт всегда остаются неизменными на практике.
type ServerOpts struct {
    CachePath string
    Port int
}
```

---

#  Настраиваемость

- Тестовые поля для поведения, специфического для тестов. Можно использовать для поведение, которое сложно тестировать.
- Пример: web приложение может заглушать OAuth чтобы использовать статические реквизиты в тестовом «режиме»
- Можно экспортировать их в функции-помощнике

---

# Пример

```go
type ServerOpts struct {
    // ..

    // Включает режим тесирования, который меняет поведение
    Test bool
}
```

---
layout: section
---

# Сложные структуры

---

# Сложные структуры

```go
type ComplexThing struct { /* ... */ }

func (c *ComplexThing) testString() string {
    // репрезентация в виде строки для сравнения в тесте
}

//------------------------------------------------------

func TestComplexThing(t *testing.T) {
    c1, c2 := createComplexThings()

    if c1.testString() != c2.testString() {
        t.Fatalf("no match:\n\n%s\n\n%s", c1.testString(), c2.testString())
    }
}
```

---

# Сложные структуры

- Деревья, связанные листы и т.д.
- Можно использовать reflect.DeepEqual или стороннюю библиотеку

---

# Пример

```go
const testSingleDepStr = `
root: root
aws_instance.bar
    aws_instance.bar -> provider.aws
aws_instance.foo
    aws_instance.foo -> provider.aws
provider.aws
root
    root -> aws_instance.bar
    root -> aws_instance.foo
`
```

---
layout: section
---

# Подпроцессы

---

# Подпроцессы

- Сложно тестировать
- Два решения:
    - Вызывать реальный подпроцесс
    - ИСпользовать заглушку

---

# Реальные подпроцессы

- Лучше исполнять реальный подпроцесс
- Проверить существование бинарника
- Убедиться, что побочные эффекты не затрагивают другие тесты

---

# Пример

```go
var testHasGit bool

func init() {
    if _, err := exec.LookPath("git"); err == nil {
        testHasGit = true
    }
}

func TestGitGetter(t *testing.T) {
    if !testHasGit {
        t.Log("git not found, skipping")
        t.Skip()
    }

    // ...
}
```

---

# Фреймворки

Сравнение:
[https://github.com/bmuschko/go-testing-frameworks](https://github.com/bmuschko/go-testing-frameworks)

---

# Итоги

- Повторяемый код в тестах – это нормально.
- Каждый тесть должен быть автономным.
- Каждый тесты должен инкапсулировать зависимости и окружение.
- Тесты должны работать в произвольном порядке.
- Изменяйте существующий код под требования тестов.

---
layout: end
---