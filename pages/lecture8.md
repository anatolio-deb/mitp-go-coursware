<!-- TODO: cancellation chapter -->
---
layout: intro
---

# Язык программирования Go
## Горутины и каналы
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 9

---
layout: section
---

# Горутины

---
layout: two-cols
---

# Пример

```go
func goroutine2() {
	time.Sleep(3 * time.Second)
	fmt.Println(4)
}

func goroutine3() {
	var i int
	for {
		i++
		time.Sleep(1 * time.Second)
		fmt.Println(i)
	}
}

func main() {
	go goroutine3()
	goroutine2()
}
```

::right::

# Вывод

```text
1
2
3
4
```

<!-- 
- Почему goroutine3 выходит из бесконечного цикла?
- Потому, что при возврате из main, все горутины экстренно завершаются.
-->
---
layout: section
---

## Пример: асинхронный сервер

---

# Идея

[uselessfacts](https://uselessfacts.jsph.pl) – API случайных фактов.

```text
$ curl "https://uselessfacts.jsph.pl/api/v2/facts/random?language=en"
{"id":"2816ebbc4eea1dfd7811ee46e3e97b33","text":"American Airlines saved $40,000 in 1987 by eliminating one olive from each salad served in first-class.","source":"djtech.net","source_url":"http://www.djtech.net/humor/useless_facts.htm","language":"en","permalink":"https://uselessfacts.jsph.pl/api/v2/facts/2816ebbc4eea1dfd7811ee46e3e97b33"}
```

---
layout: section
---

# Сервер

---

# Ответ

```go
type FactResponse struct {
	ID        string `json:"id"`
	Text      string `json:"text"`
	Source    string `json:"source"`
	SourceURL string `json:"source_url"`
	Language  string `json:"language"`
	Permalink string `json:"permalink"`
}
```

---

# Запрос

```go
func getRandomFact() FactResponse {
	f := FactResponse{}
	r, err := http.Get("https://uselessfacts.jsph.pl/api/v2/facts/random?language=en")
	if err != nil {
		log.Fatalln(err)
	}
	b, err := io.ReadAll(r.Body)
	if err != nil {
		log.Fatalln(err)
	}
	err = json.Unmarshal(b, &f)
	if err != nil {
		log.Fatalln(err)
	}
	return f
}
```

---

# Запуск сервера

```go{2|12|all}
func main() {
	ln, err := net.Listen("tcp", fmt.Sprintf("%s:%v", "localhost", 3000))
	if err != nil {
		log.Fatalln(err)
	}
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatalln(err)
			continue
		}
		handleConnection(conn)
	}
}
```

<!--
1. Что такое net.Listen и почему не http.ListenAndServe?
2. Этот сервер обрабатывает запросы последовательно. Что значит последовательно? 
-->

---

# Обработчик запроса

```go
func handleConnection(conn net.Conn) {
	defer conn.Close()
	f := getRandomFact()
	// log.Println(f.Text)
	_, err := io.WriteString(conn, f.Text)
	if err != nil {
		log.Fatalln(err)
		return
	}
}
```

---
layout: section
---

# Клиент

---

# Подключение

```go{1|2|5|6|15|all}
var facts = make(chan string, 100)
var wg sync.WaitGroup

func Connect(address string, port int) {
	defer wg.Done()
	conn, err := net.Dial("tcp", fmt.Sprintf("%s:%v", address, port))
	if err != nil {
		log.Fatalln(err)
	}
	defer conn.Close()
	r, err := io.ReadAll(conn)
	if err != nil {
		log.Fatalln(err)
	}
	facts <- string(r)
	// fmt.Println(string(r))
}
```

<!-- 
1. Буферизированный канал имеет capacity (100). Переполнение канала ведет к падению. Чтобы буферизированный канал не переполнялся, надо вовремя из него читать.

2. WaitGroup ждет завершения группы горутин. Подробнее на след. слайдах.
3. Функция Connect – это горутина, имитирующая отдельного пользователя. wg.Done – сообщает WaitGroup, что горутина завершилась, поэтому вызывается в defer последней инструкцией в горутине. defer выполняются в порядке FILO.
4. Как работает Dial?
5. Отправляем факт в канал.
-->

---

# Запуск клиента

```go{4|5|6|9|all}
func main() {
	now := time.Now()

	for time.Since(now).Seconds() < 0.000101792 {
		wg.Add(1)
		go Connect("localhost", 3000)
	}

	wg.Wait()
	fmt.Printf("Total facts collected: %v\n", len(facts))
	fmt.Printf("Time spent: %s\n", time.Since(now).String())
}
```

<!--
1. Ограничиваем время, запуска новых горутин. Чем меньше время, тем меньше горутин мы запустим. 0.000101792 – не так важно – это просто граница по времени, прошедшего после запуска main (чуть меньше секунды).
2. Добавляем горутину в WaitGroup, чтобы знала о ее существовании.
3. Запускаем горутину, которая подключается к серверу, и сразу продолжаем итерировать по циклу, создавая следующую горутину.
4. Ждем пока не завершатся все горутины.
-->

---

# Замеры

```text
Total facts collected: 50
Time spent: 20.798231926s
```

<!-- 50 фактов за 20 секунд. -->

---

# Асинхронный обработчик

```go{12|all}
func main() {
	ln, err := net.Listen("tcp", fmt.Sprintf("%s:%v", "localhost", 3000))
	if err != nil {
		log.Fatalln(err)
	}
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatalln(err)
			continue
		}
		go handleConnection(conn)
	}
}
```

<!-- Меняем обработчик на сервере на асинхронный. -->

---

# Замеры

```text
Total facts collected: 56
Time spent: 703.612501ms
```

<!-- на 6 фактов больше за 700 мс. -->

---
layout: section
---

# Каналы

---
layout: fact
---

Каналы – это механизм коммуникации, который позволяет передать данные из одной горутины в другую.

---
layout: fact
---

Каналы содержат значения определенного типа, называемого типом элемента (канала).

---

# Канал целых чисел

```go
chan int
```

# Создание канала

```go
ch := make(chan int)
```

- Как и map, канал – ссылка на структуру данных, созданную функцией make.
- Нулевое значения канала – nil.

---

# Операторы коммуникации

```go
<- // отправка 
-> // получение
```

# Пример

```go
ch <- x // отправить выражение в канал
x = <-ch // получить выражение из канала и присвоить в качестве значения
<-ch // получение без присваивания (результат опущен)
```

---

# Закрытие канала

```go
close(ch)
```

- После закрытия канала в него нельзя отправлять новые значения
- Попытка отправить в закрытый канал приведет панике

---

# Буферизированный канал

```go
ch := make(chan int) // не буферизированный канал
ch := make(chan int, 0) // не буферизированный канал
ch := make(chan int, 10)// буферизированный канал с capacity 10
```

---

# Буферизированные каналы как сигналы

Несмотря на то, что каналы предназначены для передачи данных, их можно использовать для передачи _событий_.

```go{4|11|18|all}
func main() {
	filename := "somefile.txt"
	f, _ := os.Create(filename)
	done := make(chan struct{})
	go func() {
		var b []byte
		for len(b) == 0 {
			b, _ = os.ReadFile(f.Name())
		}
		fmt.Print(string(b))
		done <- struct{}{}
	}()

	reader := bufio.NewReader(os.Stdin)
	in, _ := reader.ReadBytes('\n')
	f.Write(in)
	f.Close()
	<-done // горутина main блокируется до отправки в канал
}
```

<!-- 
1. Канал принимает пустую структуры (можно использовать bool, или 1, но структура дешевле).
2. Горутина пишет в канал, сообщая, что она закончила работу и можно считать из канала ее значение.
3. Горутина main ждет, когда можно будет считать сообщение от другой горутины.
-->

---
layout: fact
---

Если первой происходит отправка в канал, то отправляющая горутина блокируется до тех пор, пока другая корутина не получит сообщение.

Поэтому не буферизированные каналы называют _синхронными_.

---
layout: section
---

# Каналы как конвейеры

---

Каналы можно использовать для соединения горутин таким образом, что вывод одной горутины является вводом другой.

<img class="px-48" src="/public/pipeline.png"/>

---

### Пример v1

```go{2|3|4-8|9-14|15-17|all}
func main() {
	unicodes := make(chan int)
	chars := make(chan string)
	// Unicode generator
	go func() {
		for i := 65; i <= 90; i++ {
			unicodes <- i
		}
	}()
	// Unicode converter
	go func() {
		for {
			i := <-unicodes
			chars <- string(i)
		}
	}()
	// Printer
	for {
		fmt.Print(<-chars)
	}
	fmt.Print("\n")
}
```

<!--
1. Канал хранит кодировки unicode
2. Канал хранит список символов в виде строк
3. Горутина заносит коды заглавных букв английского алфавита в канал unicodes
4. Горутина читает коды из канала unicodes и заносит символьное представление кодов в канал chars
5. Горутина main получает символы из канала и печатает их
-->

---

# Пример v2

Закрытие канала означает, что он конечен.

```go{8|11|all}
func main() {
	unicodes := make(chan int)
	chars := make(chan string)
	go func() {
		for i := 65; i <= 90; i++ {
			unicodes <- i
		}
			close(unicodes) // закрываем канал
	}()
	go func() {
		for i := range unicodes { // можно итерировать по каналу
			chars <- string(i)
		}
		close(chars) // закрываем канал
	}()
	for i := range chars { // можно итерировать по каналу
		fmt.Print(i)
	}
	fmt.Print("\n")
}
```

<!-- 
1. В закрытый канал нельзя писать, можно только читать.
2. Цикл читает из канала. Когда канал закроется, он станет конечным, и поток выйдет из цикла после прочтения последнего значения в канале.
-->

---
layout: section
---

# Однонаправленные каналы

---

# Рефакторинг

Как правило, если функция принимает канал, то либо только для чтения, либо только для записи.

```go
// in – это канал получения сообщений, out – канал отправки 
func unicodeGenerator(out chan int)
func unicodeConverter(out chan string, in chan int)
func printer(in chan string)
```

## Какие проблемы у этого кода?

Ничего не мешает функциям писать в канал для чтения и читать из канала для записи.

<!-- Предыдущий код можно представить в виде трех функций.
Функция unicodeConverter находится в середине конвейера.
in – это канал получения сообщений, out – канал отправки.
Можно называть каналы таким образом, но ничего не мешает unicodeConverter отправлять в in и получать из out.
-->

---

# Два типа однонаправленных каналов

```go
// канал только для отправки int
chan<- int
// канал только для получения int
<-chan int
```

---
layout: two-cols
---

# Пример v3

```go
func unicodeGenerator(out chan<- int) {
	for i := 65; i <= 90; i++ {
		out <- i
	}
	close(out)
}

func unicodeConverter(in <-chan int, out chan<- string) {
	for i := range in {
		out <- string(i)
	}
	close(out)
}

func printer(in <-chan string) {
	for i := range in {
		fmt.Print(i)
	}
	fmt.Print("\n")
}
```

::right::

# Вывод

```go
func main() {
	unicodes := make(chan int)
	chars := make(chan string)
	go unicodeGenerator(unicodes)
	go unicodeConverter(unicodes, chars)
	printer(chars)
}
```

```text
ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

При передачи канала в функцию, его тип неявно конвертируется в тип параметра функции.

---
layout: section
---

# Буферизированные каналы

---
layout: fact
---

Буферизированный каналы – это очередь FIFO.

---

# Пустой буферезированный канал

```go
ch := make(chan, int, 3)
```

<img class="px-48" src="/public/Untitled drawing (1).png"/>

<!-- 
Отправка в канал вставляет элемент в конец очереди, а получение из канал удаляет элемент из начала.
-->

---

# Отправка в канал

```go
ch <- 1
ch <- 2
ch <- 3
ch <- 4 // заблокирует горутину
```

<img class="px-48" src="/public/channel-full.png"/>

<!-- 
Если канал полон, то отправка в канал блокирует отправляющую горутину до тех пор, пока другая горутина не освободит место в канале операцией получения.

Если канал пустой, то операция получения блокирует получающую горутину до тех пор, пока другая горутина не отправит в канал.
-->

---

# Получение из канала

```go
fmt.Println(ch<-) // 1
fmt.Println(cap(ch)) // 3
fmt.Println(len(ch)) // 2
```

<img class="px-48" src="/public/channel-full-partially.png" />

---
layout: fact
---

Не используйте каналы как очередь в одной горутине. Если вам нужна структура данных очередь, используйте slice. Каналы нужны для синхронизаци горутин.

---
layout: section
---

# Мультиплексирование select

---

# Пример

```go{1-8|11-23|all}
func fib1(n int, results chan<- int) int {
	if n < 2 {
		return n
	}
	r := fib1(n-1, results) + fib1(n-2, results)
	results <- r
	return r
}

// fib2 использует кэш для оптимизации рекурсивных вызовов.
func fib2(n int, cache map[int]int, results chan<- int) int {
	r, ok := cache[n]

	if ok {
		return r
	}

	if n < 2 {
		return n
	}
	cache[n] = fib2(n-1, cache, results) + fib2(n-2, cache, results)
	results <- cache[n]
	return cache[n]
}
```

---
layout: two-cols
---

```go{2|3-6|9,10,18,26|11-17,19-25|all}
func main() {
	const fibOf43 int = 433494437 // до каких пор считать
	res1, res2 := make(chan int, 43), make(chan int, 43)
	cache := make(map[int]int)
	go fib1(43, res1)
	go fib2(43, cache, res2)
	fmt.Println("the winner is:")
	for {
		select {
		case x, ok := <-res1:
			if !ok {
				fmt.Println("fib1")
				return
			}
			if x == fibOf43 {
				close(res1)
			}
		case x, ok := <-res2:
			if !ok {
				fmt.Println("fib2")
				return
			}
			if x == fibOf43 {
				close(res2)
			}
		}
	}
}
```

::right::

```text
the winner is:
fib2
```

<!-- 
1. Верхняя граница последовательности
2. Канал для горутины fib1
3. Канал и кэш для горутины fib2
4. select работает как switch, но с каналами. Он ждет кагда какой либо канал в кейсе освободится для коммуникации, и тогда выполняет тело кейса. ok – это флаг, чтобы проверить закрыт/заполнен канал или нет. Если закрыт/заполнен, то ok == false
5. Если !ok значит, канал уже закрыт, значит нужное значение было уже получено. Если ok, значит канал еще открыт для записи, горутина работает, продолжать искать нужное значение. Если нужно значение найдено, значит горутина завершила свою работу, канал можно закрыть. На следующей итерации выход из цикла.
6. Горутины заполняют свои каналы, а select ждет, когда там появится определенное значение.
-->


---
layout: end
---