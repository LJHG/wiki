<body>
  <main class="content" role="main">
    <div class="archive">
    </div>
  </main>
  <script>
    var url = "./archive.json"
    var request = new XMLHttpRequest();
    request.open("get", url);
    request.send(null);
    request.onload = function () {
      var articles = null
      if (request.status == 200) {
        articles = JSON.parse(request.responseText);
      }
      writeContent(articles);
    }
    function writeContent(articles) {
      var years = []
      for (year in articles) {
        years.push(year)
      }
      function cmp(a, b) {
        return b - a;
      }
      //对年份从大到小进行排序
      years.sort(cmp)
      for (var idx in years) {
        yearArticles = articles[years[idx]]
        var year = document.createElement("h2");
        year.className = "archive-title"
        year.textContent = years[idx]
        document.getElementsByClassName("archive")[0].appendChild(year);
        for (var i = 0; i < yearArticles.length; i++) {
          var _article = yearArticles[i];
          var article = document.createElement("article");
          article.className = "archive-item"
          var link = document.createElement("a")
          link.href = _article.url
          link.className = "archive-item-link"
          link.textContent = _article.title
          var date = document.createElement("span")
          date.className = "archive-item-date"
          date.textContent = _article.date
          article.appendChild(link)
          article.appendChild(date)
          document.getElementsByClassName("archive")[0].appendChild(article);
        }

      }
    }
  </script>

</body>