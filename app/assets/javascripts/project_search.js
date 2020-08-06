(function(){
  var renderResult = (result) => (`
      <div class="card">
        <div class="card-header">
          ${result.brigade.name}
          /
          ${result.project.name}
          <a href="${result.project.code_url}" target="_blank"><i class="fab fa-github"></i></a>
        </div>
        <div class="card-body">
          ${(result.search_properties.github_languages || '').split('|')}
          ${(result.search_properties.github_topics || '').split('|')}
          <h4 class="card-title">${result.search_properties.github_readme_title}</h4>
          <p>${result.search_properties.github_readme_first_paragraph}</p>
          ${JSON.stringify(result)}
        </div>
      </div>
    `);
  var replaceResults = (results) => {
    $('#results').html(results.map(renderResult));
  };
  var performSearch = (q) => {
    if (q.trim().length === 0) {
      return;
    }

    var response = fetch('/projects/search?q=' + q.trim())
      .then(resp => resp.json())
      .then(json => replaceResults(json))
      .catch(err => console.error(err));
  };

  $(document).on('keyup', '#q', (e) => { performSearch(e.target.value) });
})();
