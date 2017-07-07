#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://es.wikipedia.org/wiki/Elecciones_legislativas_de_Argentina_de_2013',
  after: '//span[@id="Diputados_elegidos"]',
  xpath: './/table[1]//tr//td[1]//a[not(@class="new")]/@title',
)
warn " = #{names.count} people"

# Position = Member of Argentine Chamber of Deputies
sparq = <<EOQ
  SELECT ?item ?start ?end WHERE {
    ?item p:P39 ?posn .
    ?posn ps:P39 wd:Q18229570 ; pq:P580 ?start .
    OPTIONAL { ?posn pq:P582 ?end }
    FILTER (?start >= "2013-01-01T00:00:00Z"^^xsd:dateTime || ?end >= "2013-01-01T00:00:00Z"^^xsd:dateTime) .
  }
EOQ
ids = EveryPolitician::Wikidata.sparql(sparq)

EveryPolitician::Wikidata.scrape_wikidata(ids: ids, names: { es: names })
