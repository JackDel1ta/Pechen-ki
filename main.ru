import requests

HEADERS = {"User-Agent": "MySearchTool/1.0 (educational project)"}

# ---------- GitHub ----------
def search_github(name):
    """Публичные профили GitHub."""
    url = "https://api.github.com/search/users"
    params = {"q": name}
    headers = {**HEADERS, "Accept": "application/vnd.github+json"}
    r = requests.get(url, params=params, headers=headers, timeout=15)
    r.raise_for_status()
    items = r.json().get("items", [])
    return [
        {"source": "GitHub", "title": u["login"], "url": u["html_url"]}
        for u in items[:10]
    ]

# ---------- Wikipedia (английская) ----------
def search_wikipedia_en(name):
    """Статьи в английской Википедии."""
    url = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "list": "search",
        "srsearch": name,
        "format": "json",
        "srlimit": 10,
    }
    r = requests.get(url, params=params, headers=HEADERS, timeout=15)
    r.raise_for_status()
    items = r.json().get("query", {}).get("search", [])
    return [
        {
            "source": "Wikipedia (EN)",
            "title": i["title"],
            "url": f"https://en.wikipedia.org/wiki/{i['title'].replace(' ', '_')}",
        }
        for i in items
    ]

# ---------- Wikipedia (русская) ----------
def search_wikipedia_ru(name):
    """Статьи в русской Википедии."""
    url = "https://ru.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "list": "search",
        "srsearch": name,
        "format": "json",
        "srlimit": 10,
    }
    r = requests.get(url, params=params, headers=HEADERS, timeout=15)
    r.raise_for_status()
    items = r.json().get("query", {}).get("search", [])
    return [
        {
            "source": "Wikipedia (RU)",
            "title": i["title"],
            "url": f"https://ru.wikipedia.org/wiki/{i['title'].replace(' ', '_')}",
        }
        for i in items
    ]

# ---------- Open Library (авторы книг) ----------
def search_openlibrary(name):
    """Авторы в Open Library."""
    url = "https://openlibrary.org/search/authors.json"
    params = {"q": name, "limit": 10}
    r = requests.get(url, params=params, headers=HEADERS, timeout=15)
    r.raise_for_status()
    items = r.json().get("docs", [])
    return [
        {
            "source": "Open Library",
            "title": i.get("name", "?"),
            "url": f"https://openlibrary.org/authors/{i['key'].split('/')[-1]}",
        }
        for i in items
    ]

# ---------- Stack Exchange (StackOverflow и др.) ----------
def search_stackexchange(name):
    """Пользователи на Stack Exchange."""
    url = "https://api.stackexchange.com/2.3/users"
    params = {
        "order": "desc",
        "sort": "reputation",
        "inname": name,
        "site": "stackoverflow",
    }
    r = requests.get(url, params=params, headers=HEADERS, timeout=15)
    r.raise_for_status()
    items = r.json().get("items", [])
    return [
        {
            "source": "StackOverflow",
            "title": i.get("display_name", "?"),
            "url": i.get("link", ""),
        }
        for i in items[:10]
    ]

# ---------- Главная функция ----------
def main():
    query = input("Введите имя или ник для поиска: ").strip()
    if not query:
        print("Пустой запрос.")
        return

    searchers = [
        ("GitHub", search_github),
        ("Wikipedia EN", search_wikipedia_en),
        ("Wikipedia RU", search_wikipedia_ru),
        ("Open Library", search_openlibrary),
        ("StackOverflow", search_stackexchange),
    ]

    all_results = []
    for name, fn in searchers:
        print(f"\n[{name}] ищу...")
        try:
            results = fn(query)
            print(f"  найдено: {len(results)}")
            all_results.extend(results)
        except Exception as e:
            print(f"  ошибка: {e}")

    print("\n" + "=" * 50)
    print(f"ИТОГО найдено: {len(all_results)}")
    print("=" * 50)
    for r in all_results:
        print(f"[{r['source']}] {r['title']}\n    {r['url']}")

if __name__ == "__main__":
    main()
