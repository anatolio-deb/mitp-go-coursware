---
layout: intro
---

# Язык программирования Go
## Асинхронность с общими переменными
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 9

---
layout: section
---

# Условия гонки

---

# Последовательное исполнение

```text
инструкция 1
инструкция 2
...
инструкция n
```

Инструкция 1 исполняется после инструкции 2

---

# Понятие асинхронности

```text
горутина 1 ( 
    инструкция 1
    событие x 
    инструкция n
    )
горутина 2 (
    инструкция 1
    событие y
    инструкция n
    )
```

- Событие – это инструкция горутины, которая обращается к механизму синхронизации, например, отправляет данные в канал.
- Можно сказать, что события делятся на события чтения и события записи. 
- Инструкции в горутинах исполняются последовательно, но какое событие произойдет первым?

<!-- Мы не можем уверено сказать, произойдет ли событие x после события y, до него или они произойдут одновремнно. Это значит, что события x и y асинхронны.  -->

---
layout: section
---

## Асинхронно-безопасный код

---
layout: fact
---

Функция является _асинхронно-безопасной_, если ее поведение одинаково правильно в последовательном и асинхронном коде без дополнительной синхронизации.

---
layout: fact
---

Тип является асинхронно-безопасным, если все его экспортированные методы асинхронно-безопасны.

---

# При этом

<v-clicks>

- Необязательно делать асинхронно-безопасным каждый конкретный тип, чтобы сделать асинхронно-безопасной программу.
- Асинхронно-безопасные типы – исключения, а не правила.
- Обращайтесь к переменной асинхронно только в том случае, если в документации ее типа написано, что это безопасно.
- Мы не обращаемся к переменным одновременно из нескольких горутин.
- Переменная ограничивается областью видимости одной горутины или с помощью механизма взаимных исключений.
- Функции, экспортированные на уровне пакета, принято делать асинхронно-безопасными.
- Переменные, объявленные на уровне пакета нельзя ограничить областью видимости одной горутины, поэтому функции, которые их изменяют, должны использовать механизм взаимных исключений.

</v-clicks>

---
layout: fact
---

Условия гонки – это ситуация в программе, когда две горутины обращаются к переменной, и одно из обращений – запись.

---

# Пример

```go
var x int

func main() {
    go func() {
        x++ // первое небезопасное обращение
    }()
    x++ // второе небезопасное обращение
    fmt.Println(x) // 1
}
```

---

# Идеальная последовательность событий

<div class="px-48">
    <style type="text/css">
    .tg  {border-collapse:collapse;border-spacing:0;}
    .tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
    overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
    font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg .tg-yofg{background-color:#9aff99;text-align:left;vertical-align:top}
    .tg .tg-0lax{text-align:left;vertical-align:top}
    </style>
    <table class="tg">
    <thead>
    <tr>
        <th class="tg-0lax">горутина 1</th>
        <th class="tg-0lax">горутина 2</th>
        <th class="tg-0lax"></th>
        <th class="tg-0lax">x</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax">чтение</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">&lt;-</td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-yofg">инкремент</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax">запись</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">-&gt;</td>
        <td class="tg-0lax">1</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">чтение</td>
        <td class="tg-0lax">&lt;-</td>
        <td class="tg-0lax">1</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-yofg">инкремент</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">1</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">запись</td>
        <td class="tg-0lax">-&gt;</td>
        <td class="tg-0lax">2</td>
    </tr>
    </tbody>
    </table>
</div>

---

# На самом деле

<div class="px-48">
    <style type="text/css">
    .tg  {border-collapse:collapse;border-spacing:0;}
    .tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
    overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
    font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg .tg-yofg{background-color:#9aff99;text-align:left;vertical-align:top}
    .tg .tg-0lax{text-align:left;vertical-align:top}
    </style>
    <table class="tg">
    <thead>
    <tr>
        <th class="tg-0lax">горутина 1</th>
        <th class="tg-0lax">горутина 2</th>
        <th class="tg-0lax"></th>
        <th class="tg-0lax">x</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax">чтение</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">&lt;-</td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">чтение</td>
        <td class="tg-0lax">&lt;-</td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-yofg">инкремент</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-yofg">инкремент</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">0</td>
    </tr>
    <tr>
        <td class="tg-0lax">запись</td>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">-&gt;</td>
        <td class="tg-0lax">1</td>
    </tr>
    <tr>
        <td class="tg-0lax"></td>
        <td class="tg-0lax">запись</td>
        <td class="tg-0lax">-&gt;</td>
        <td class="tg-0lax">1</td>
    </tr>
    </tbody>
    </table>
</div>



---

# Fix: каналы

```go
var c chan int

func main() {
	c := make(chan int)
	go func() {
		x := 0 // общая переменная переносится в горутину и становится локальной
		x++ // чтение, инкремент, запись
		c <- x
		close(c)
	}()
	x := <-c
	x++
	fmt.Println(x)
}
```

<!--
Канал блокирует горутины, операции над каналами последовательны.
-->

---
layout: section
---

## Взаимные исключения

---
layout: section
---

# Но сначала семафоры

---
layout: fact
---

Придуманы в Unix для синхронизации потоков и процессов ОС, реализованы на C.

---

## Пример использования: гонка данных двух потоков

```c
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>

#define NITER 1000000

int cnt = 0;

// Эта потоковая функция
void * Count(void * a)
{
    int i, tmp;
    for(i = 0; i < NITER; i++)
    {
        tmp = cnt;      // локальная копия глобальной cnt
        tmp = tmp+1;    // инкремент локальной копии
        cnt = tmp;      // сохранить локальное значение в глобальную cnt
    }
}
```

<!-- 
Counter записывает NITER в cnt
-->

---

```c{3|4-5|6-7|9-12|all}
int main(int argc, char * argv[])
{
    pthread_t tid1, tid2;
    pthread_create(&tid1, NULL, Count, NULL);
    pthread_create(&tid2, NULL, Count, NULL);
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);

    if (cnt < 2 * NITER) 
        printf("\n Бум! cnt [%d], должно быть %d\n", cnt, 2*NITER);
    else
        printf("\n OK! cnt [%d]\n", cnt);
    pthread_exit(NULL);
}
```

<!--
1. Объявляем потоки
2. Запускаем потоки
3. Ждем завершения потоков
4. По идее мы должны получить значение 2000000, так как каждый поток пишет в cnt 1000000 значений.
-->

---

# Вывод

Docker, arm64, Debian bullseye, gcc 10.2.1

```text
Бум! cnt [1031954], должно быть 2000000
```

# Почему?

Потоки записывают данные в счетчик одновременно, а не последовательно, один за другим, поэтому 2000000-1031954 операций присваивания не увеличивают счетчик (n=n).

---

# Fix: семафоры POSIX

```c{9|14|23|all}
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>

#define NITER 1000000

int cnt = 0;
sem_t mutex;

void * Count(void * a)
{
    int i, tmp;
    sem_wait(&mutex);
    // критическая секция
    for(i = 0; i < NITER; i++)
    {
        tmp = cnt;
        tmp = tmp+1;
        cnt = tmp;
    }
    // сигнал
    sem_post(&mutex);
}
```

<!--
1. Объявление семафоры
2. Заблокировать поток на время исполнения цикла
3. Будит заблокированный поток, ожидающий семафору, инкремент значения семафоры

Похоже на WaitGroup.
-->


---

```c{4|14|all}
int main(int argc, char * argv[])
{
    pthread_t tid1, tid2;
    sem_init(&mutex, 0, 1);
    pthread_create(&tid1, NULL, Count, NULL);
    pthread_create(&tid2, NULL, Count, NULL);
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);

    if (cnt < 2 * NITER) 
        printf("\n Бум! cnt [%d], должно быть %d\n", cnt, 2*NITER);
    else
        printf("\n OK! cnt [%d]\n", cnt);
    sem_destroy(&mutex);
    pthread_exit(NULL);
}
```

<!--
1. Инициализация семафоры со значением: арг1 семафора, арг2 влаг – будет ли работать семафора с процессами или с потоками, арг3 – количество неблокирующих потоков.
2. Разрушить семафору. Очистка памяти?
-->

---

# Вывод

```text
OK! cnt [2000000]
```

- Потоки взаимно блокируется на время исполнения цикла каким-либо из потоков
- Код, расположенный между блокировкой и разблокировкой семафоры, называется _критической секцией_.

---


|     **Поток 1**    |     **Поток 2**    |    | данные |
|:------------------:|:------------------:|----|--------|
| sem_wait (&mutex); |         ---        |    | 0      |
|         ---        | sem_wait (&mutex); | <- | 0      |
| a = data;          | /* заблокирован */ | <- | 0      |
| a = a+1;           | /* заблокирован */ |    | 0      |
| data = a;          | /* заблокирован */ |    | 1      |
| sem_post (&mutex); | /* заблокирован */ | -> | 1      |
| /* заблокирован */ | a = data;          | -> | 1      |
| /* заблокирован */ | a = a+1;           |    | 1      |
| /* заблокирован */ | data = a;          |    | 2      |
| /* заблокирован */ | sem_post (&mutex); |    | 2      |

---

# Пример

https://go.dev/play/p/tnS-ewMvXFV

```go
const upper = 1000000
var wg sync.WaitGroup
var cnt int

func main() {
	wg.Add(2)
	for i := 0; i < 2; i++ {
		go func() {
			var tmp int
			for i := 0; i < upper; i++ {
				tmp = cnt
				tmp++
				cnt = tmp
			}
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(cnt) // 1654645
}
```

---

# Семафора

https://go.dev/play/p/1hORsN05FRv

```go{4|11|17|all}
const upper = 1000000
var wg sync.WaitGroup
var cnt int
var sem = make(chan struct{}, 1) // охраняет счетчик

func main() {
	wg.Add(2)
	for i := 0; i < 2; i++ {
		go func() {
			var tmp int
			sem <- struct{}{} // заблокировать другие горутины
			for i := 0; i < upper; i++ {
				tmp = cnt
				tmp++
				cnt = tmp
			}
			<-sem // разблокировать другие горутины
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(cnt) // 2000000
}
```

<!--
1. Канал может хранить только одну структуру – только одна горутина может иметь доступ к общей переменной.
2. После записи в канал другие горутины не могут в него писать, и они ждут, когда канал освободится.
3. После чтения из канала другие горутины могут в него писать
-->

---

# sync.Mutex

https://go.dev/play/p/NsbDmm-ywYz

```go{4|11|17|all}
const upper = 1000000
var wg sync.WaitGroup
var cnt int
var mu sync.Mutex // охраняет счетчик

func main() {
	wg.Add(2)
	for i := 0; i < 2; i++ {
		go func() {
			var tmp int
			mu.Lock()
			for i := 0; i < upper; i++ {
				tmp = cnt
				tmp++
				cnt = tmp
			}
			mu.Unlock()
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(cnt) // 2000000
}
```

---

# Шаблон

```go
func f(){
    mu.Lock()
    defer mu.Unlock()
    /* work */
}
```

---
layout: section
---

# Атомарные операции

---
layout: fact
---

Атомарными операциями называются такие операции, которые изменяют значение переменной один раз за единицу процессорного времени, исключаю общий доступ к этой переменной из других областей памяти.

---
layout: section
---

## Взаимная блокировка

---

# Пример: игровой инвентарь

Инвентарь является общим для команды игроков

```go
type item struct { weight float32 }

type sharedInventory struct {
	items    map[item]int
	capacity int
}

type Player struct{ inventory sharedInventory }
```

---

# Методы инвентаря

```go
// асинхронно-безопасная функция
func (s *sharedInventory) Increase(by int) {
	mu.Lock()
	defer mu.Unlock()
	s.capacity += by
}

// асинхронно-безопасная функция
func (s *sharedInventory) Load() float32 {
	mu.Lock()
	defer mu.Unlock()
	var l float32
	for i, q := range s.items {
		l += i.weight * q
	}
	return l
}
```

---

# Метод игрока

Много вызовов Lock/Unlock

```go{1|2|3|4-9|all}
// NOTE: не атомарная функция!
func (p player) Put(i item, q int) {
	w := (i * q)
	p.inventory.Increase(-w)
	if p.inventory.Load() < 0 {
		p.inventory.Increase(w)
        fmt.Println("Недостаточно места")
	} else {
        p.inventory[i] = q
    }
}
```



<!--
1. Игрок может положить в инвентарь элементы в n-ом количестве
2. Считаем общий вес количества элементов
3. Может ли инвентарь вместить количество элементов?
4. Если нет, то вернуть прежнее значение вместимости инвентаря
5. Если есть, то положить элемент в n-ом количестве

Вернуться на строчку 3. Эта операция изменяет временно вместимость инвентаря, но если в это время другие игроки будут класть что-то в инвентарь, то они не смогут этого сделать в том случае, пока вместимость инвентаря остается отрицательной. Не атомарность функции выражается в том, что функция использует много операций с блокировками. Атомарная функция блокирует на все время исполнения инструкций. Между вызовами методов инвентаря есть временной зазор в котором инвентарь не защищен от доступа другими горутинами. 
-->

---

# Попытка исправить

```go
// NOTE: неправильно
func (p player) Put(i item, q int) {
    mu.Lock() // Put блокирует на время исполнения своего тела
    defer mu.Unlock() // Выполнится в конце тела
	w := (i * q)
	p.inventory.Increase(-w) // Повторная блокировка
	if p.inventory.Load() < 0 {
		p.inventory.Increase(w)
        fmt.Println("Недостаточно места")
	} else {
        p.inventory[i] = q
    }
}
```

### В итоге

- `p.sharedInventory.Increase(-w)` ждет, когда заблокируется `Put`, чтобы начать работу.
- `Put` не может продолжить работу, пока не выполнится `p.sharedInventory.Increase(-w)`
- `Put` никогда не завершит исполнение, deadlock!

---

# Fix: атомарность

```go
// этой функции нужна блокировка
func increase(s *sharedInventory, by int) {
	s.capacity += by
}

func (s *sharedInventory) Increase(by int) {
	mu.Lock()
	defer mu.Unlock()
	increase(&s, by)
}

func (p player) Put(i item, q int) {
	mu.Lock()
	defer mu.Unlock()
	w := (i * q)
	incerase(&p.inventory, -w)
	if p.sharedInventory.Load() < 0 {
		incerase(&p.inventory, w)
	} else {
		fmt.Println("Недостаточно места")
	}
}
```

---

# Выводы

- При использовании Mutex не экспортируйте охраняемые переменные
- Инкапсулируйте общедоступные переменные
- Каналы – отличный встроенный способ синхронизации
- WaitGroup – по сути семафора, но он не влияет на последовательность событий внутри горутин
- Семафоры – это просто блокировка переключения контекста между горутинами на уровне процессора.
- Семафоры и другие примитивы синхронизации не защищают область памяти переменной, а управляют процессорном временем.

---

# Самостоятельно

- sync.RWMutex – блокировка только записи
- sync.Once – ленивая инициализация
- флаг `-race` компилятора go помогает найти в коде условия гонки
- Потоки в Go

---
layout: end
---