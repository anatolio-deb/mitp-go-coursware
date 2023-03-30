---
layout: intro
---

# Язык программирования Go
## Методы
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 6

---
layout: fact
---

Методы – это функции, привязанные к какому-то типу.

<!-- Рассказать про ООП вообще:
1. Как понимаются методы в других языках?
2. Что такое объект вообще и в Go в частности? 

В Go объект – это переменная.-->

---

# Пример №1

```go
const m = 1 * time.Minute
fmt.Println(m.Seconds())    // 60
```

<!-- Seconds – метод типа Duration. -->

---

# Пример №2

```go
func (m Mile) String() string {
	return fmt.Sprintf("%g mi", m)
}
```

<!-- Уже знакомый метод String для Мили -->

---
layout: section
---

# Объявление методов

---

# Дополнительный параметр

```go
type User struct {
	ID      int
	Friends map[int]User
}

// Традиционная функция
func IsFriend(u1, u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}

// Метод типа User
func (u1 User) IsFriend(u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}
```

- Дополнительный параметр u1 называется _ресивером_
- Никаких this и self
- Называть ресивер можно как любые другие переменные
- Общепринятый шаблон: первая буква соответствующего типа (u для User) 

<!-- Ничем не отличается от объявления функции, кроме дополнительного параметра перед именем функции, который прикрепляет функцию к типу этого параметра.
Название ресивер – это наследие ранних ООП языков, в которых вызов метода понимался как "передача сообщения объекту".
Можно иметь одноименные функцию и метод структуры.
-->

---

# Пример

```go
u1 := User{ID: 1, Friends: make(map[int]User)}
u2 := User{ID: 2}
fmt.Println(u1.IsFriend(u2)) // false
u1.Friends[u2.ID] = u2
fmt.Println(u1.IsFriend(u2)) // true
```

- Выражение u1.IsFriend называется _селектором_ (выбирает соответствующий метод IsFriend ресивера u1 типа User)
- Поля и методы структуры разделяют одно пространство имен (нельзя называть поле и метод одним именем)

---

# Методы типов

Можно иметь разные типы с одноименными методами.

```go
type ID int

type User struct {
	ID      ID
	Friends map[ID]User
}

func (i ID) IsFriend(u User) bool {
	_, ok := u.Friends[i]
	return ok
}

func main() {
	u1 := User{ID: 1, Friends: make(map[ID]User)}
	u2 := User{ID: 2}
	u1.Friends[u2.ID] = u2
	fmt.Println(u2.ID.IsFriend(u1)) // true
}
```

---
layout: section
---

## Методы с указателем на ресивер

---

# Без указателя

При вызове значение u1 копируется в тело функции.

```go
func (u1 User) IsFriend(u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}
```

## Где использовать?

- В примитивных типах
- В несложных структурах с полями примитивных типов

---

# Указатель

Функция получает доступ к u1 по адресу.

```go
func (u1 *User) IsFriend(u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}
```

## Где использовать?

- Типы с большим количеством значений
- Поля структур, которые хранят много значений 

---
layout: fact
---

Если в каком-либо методе типа определен указатель на ресивер, то все методы должны следовать этому.

---
layout: fact
---

Нельзя определять методы на типах, которые сами являются указателями

---

# Пример

```go
type ID *int

func (ID) f() { /* ... */ } // compile error: invalid receiver type
```

---

# Вызвать (*User).IsFriend можно так:

```go
r := &User{}
fmt.Println(r.IsFriend(User{})) // false
```

## Или так:

```go
u := User{}
uptr := &u
fmt.Println(uptr.IsFriend(User{})) // false
```

## Или так:

```go
u := User{}
fmt.Println((&u).IsFriend(User{})) // false
```

---

# Почему это работает?

```go
type User struct {
	ID      int
	Friends map[int]User
}

func (u1 *User) IsFriend(u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}

func main() {
    u := User{ID: 1, Friends: make(map[int]User)}
    fmt.Println(u.IsFriend(User{})) // false
}
```

<!-- Вопрос: В качестве ресивера метода IsFriend объявлен указатель *User. В main IsFriend вызывается на самой переменной, а не на структуре. Почему нет ошибки?

Ответ: если ресивер u – это переменная типа User, но метод требует ресивер *User, можно использовать сокращение: u.IsFriend. При этом компилятор сделает &u неявно.
-->

---

### Нельзя вызвать метод на временной переменной без адреса

```go
User{ID: 1, Friends: make(map[int]User)}.IsFirend(User{Friends: make(map[int]User)}) // compile error: can't take address of User literal
```

<!-- Потому, что невозможно получить адрес временной переменной. -->

---

# Почему это работает?

```go
type User struct {
	ID      int
	Friends map[int]User
}

func (u1 *User) IsFriend(u2 User) bool {
	_, ok := u1.Friends[u2.ID]
	return ok
}

func main() {
    u := User{ID: 1, Friends: make(map[int]User)}
    uptr := &u
    fmt.Println(uptr.IsFriend(User{})) // false
}
```

<!-- Вопрос: в функции main метод IsFriend вызывается на указателе ptr, а не на самой переменной u. Почему нет ошибки?

Ответ: компилятор делает неявное *ptr, и получает значение. -->

---

# В итоге

Если аргумент и параметр ресивера имеют один тип T или *T, то:

```go
User{}.IsFriend(User{}) // User
uptr.IsFriend(User{})   // *User
```

Или аргумент ресивера – это переменна типа T, а параметр ресивера имеет тип *T, то:

```go
u.IsFriend(User{})  // неявное (&u)
```

Или аргумент ресивер типа T*, а параметр T:

```go
uptr.IsFriend(User{}) // неявное (*uptr)
```

Если все методы типа имеют ресивер типа T, а не *T, то экземпляры этого типа безопасны к копированию.

---
layout: section
---

# nil как значение ресивера

---

```go
type User struct {
	ID       int
	Friends  map[int]*User
	Soulmate *User
}

func (u *User) TotalRelations() int {
	if u == nil {
		return 0
	}

	l := len(u.Friends)

	if u.Soulmate != nil {
		l += 1
	}
	return l
}

func main() {
	uptr := &User{Friends: map[int]*User{1: &User{}}}
	fmt.Println(uptr.TotalRelations()) // 1
	uptr = nil
	fmt.Println(uptr.TotalRelations()) // 0
}
```

<!-- Методы, как и функции, могут принимать нулевой указатель.

TotalRelations работает на nil потому, что, в данном случае, nil – это нулевое значение типа User, объявленного в uptr до обнуления.

-->

---
layout: fact
---

Документируйте методы, которые принимают nil как значение ресивера.

---

# Пример из стандартной библиотеки

```go
// Get gets the first value associated with the given key.
// If there are no values associated with the key, Get returns
// the empty string. To access multiple values, use the map
// directly.
func (v Values) Get(key string) string {
	if v == nil {
		return ""
	}
	vs := v[key]
	if len(vs) == 0 {
		return ""
	}
	return vs[0]
}
```
---
layout: section
---

## Композиция типов встраиванием структур

---

# PremiumUser – __это не__ User (как при наследовании)

```go
type User struct {
	ID       int
	Friends  map[int]User
	Soulmate *User
}

type PremiumUser struct {
	User
	Money float64
}

func main() {
	var p PremiumUser
	p.ID = 1
	fmt.Println(p.User.ID) // 1
	p.User.Friends = make(map[int]User)
	fmt.Println(r.Friends) // map[]
}
```

<!-- 

С точки зрения ООП языков, это выглядит как наследование.

К этим полям можно обращаться как напрямую, так и через точку.

Если мы определяем в поле структуры тип без имени, то в качестве имени компилятор использует название типа.

При этом все поля User становятся частью PremiumUser. 

В Go нет сложной иерархии типов, поэтому наследование – это композиция. -->

---

# Методы ведут себя как поля

```go
type User struct {
	ID       int
	Friends  map[int]User
	Soulmate *User
}

func (u User) AddFriend(user User) {
	u.Friends[user.ID] = user
}

type PremiumUser struct {
	User
	Money float64
}

func main() {
	var p PremiumUser
	var u User
	p.Friends = make(map[int]User)
	p.AddFriend(u)
}
```

---

## PremiumUser __содержит__ User (как при композиции)

```go
type User struct {
	ID       int
	Friends  map[int]User
	Soulmate *User
}

func (u User) AddFriend(user User) {
	u.Friends[user.ID] = user
}

type PremiumUser struct {
	User
	Money float64
}

func main() {
	var u User
	u.Friends = make(map[int]User)
	var p PremiumUser
	u.AddFriend(p) // cannot use p (variable of type PremiumUser) as User value in argument to u.AddFriend
```

---

# Что происходит при встраивании?

```go
type User struct {
	ID       int
	Friends  map[int]User
	Soulmate *User
}

func (u User) AddFriend(user User) {
	u.Friends[user.ID] = user
}

type PremiumUser struct {
	User
	Money float64
}
```

Компилятор генерирует дополнительные методы-обертки, делегирующие вызовы уже объявленным методам:

```go
func (p PremiumUser) AddFriend(user User) {
    return p.User.AddFriend(user)
}
```

---

# Анонимное поле с указателем

```go {12|17,18,19,20}
type User struct {
	ID       int
	Friends  map[int]User
	Soulmate *User
}

func (u User) AddFriend(user User) {
	u.Friends[user.ID] = user
}

type PremiumUser struct {
	*User
	Money float64
}

func main() {
	p1 := PremiumUser{&User{ID: 1}, 0.0}
	p2 := PremiumUser{&User{ID: 2}, 0.0}
	p1.User = p2.User // p1 и p2 ссылаются на одного и того же пользователя
	fmt.Println((*p1.User).ID, (*p2.User).ID) // 2 2
}
```

---
layout: section
---

# Значения методов

---

# Метод как функция

```go
u1 := User{ID: 1}
u1.Friends = make(map[int]User)
u2 := User{ID: 2}
addFriend := u1.AddFriend // значение метода
addFriend(u2)
fmt.Println(u1.IsFriend(u2))  // true
```

Функция addFriend может вызываться без ресивера

<!-- Значения методов полезны, когда API какого-либо пакета требует значения функции, но у клиента в качестве этой функции существует метод с конкретным ресивером.   -->

---

# Пример

```go
func (u User) Notify() { /* ... */ }

func (u User) AddFriend(user User) {
	u.Friends[user.ID] = user
	time.AfterFunc(60 * time.Second, func() { user.Notify() })
}
```

<!-- Notify уведомляет пользователя, которого добавили в друзья, о том, что его добавили в друзья -->

## Или

```go
u.Friends[user.ID] = user
time.AfterFunc(60 * time.Second, user.Notify)
```

---

# Выражения методов

Позволяют получить обычную функцию из метода T.f или (*T).f типа T.

```go
u1 := User{ID: 1}
u1.Friends = make(map[int]User)
u2 := User{ID: 2}
addFriend := User.AddFriend // выражение метода
addFriend(u1, u2)
fmt.Println(u1.IsFriend(u2)) // true
fmt.Printf("%T\n", addFriend) // func(main.User, main.User)
```

Функция принимает ресивер первым параметром.

Выражения методов бывают полезны, когда нужно значение, которое представляет выбор между несколькими методами, принадлежащими одному типу 

---

# Пример

```go
func (u User) RemoveFriend(user User) { delete(u.Friends, user.ID)}

func InverseRelation(u User, users []User) {
	var action func(u1, u2 User)
	for _, user := range users {
		if user.IsFriend(u) {
			action = User.RemoveFriend
		} else {
			action = User.AddFriend
		}
		action(user, u)
	}

}

func main() {
	u1, u2, u3 := User{ID: 1}, User{ID: 2}, User{ID: 3}
	u2.Friends, u3.Friends = map[int]User{u1.ID: u1}, map[int]User{}
	fmt.Println(u2.IsFriend(u1)) // true
	fmt.Println(u3.IsFriend(u1)) // false
	users := []User{u2, u3}
	InverseRelation(u1, users)
	fmt.Println(u2.IsFriend(u1)) // false
	fmt.Println(u3.IsFriend(u1)) // true
}
```


<!-- InverseRelations удаляет пользователя из друзей других пользователей, если он есть у них в друзьях, иначе – добавляет его в друзья других пользователей. 

Выражения методов полезны, когда нам нужно значение, представляющее выбор между несколькими методами одного типа, чтобы вызывать методы со множеством разных ресиверов.
-->

---
layout: section
---

# Инкапсуляция

---

# Пример

```go
type User struct {
	id       int
	friends  map[int]User
	soulmate *User
}

func (u User) ID() { return u.id }

func (u User) SetID(id int) { u.id = id }

func (u User) RemoveFriend(user User) { delete(u.Friends, user.ID)}

func (u User) AddFriend(user User) { u.Friends[user.ID] = user }

func (u User) TotalRelations() int {
    var l int
    if u.friends != nil {
        l := len(u.Friends)
    }
    if u.soulmate != nil {
        l += 1
    }
    return l
} 

```

<!-- Инкапсуляцию составляют методы и не экспортированные поля.
В именах геттеров принято опускать слово "Get". -->

---
layout: end
---