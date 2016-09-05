#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

warn "2013 election"
names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://es.wikipedia.org/wiki/Elecciones_legislativas_de_Argentina_de_2013',
  after: '//span[@id="Diputados_elegidos"]',
  xpath: './/table[1]//tr//td[1]//a[not(@class="new")]/@title',
)
warn " = #{names.count} people"
EveryPolitician::Wikidata.scrape_wikidata(names: { es: names }, batch_size: 100)


# -------------------------------------------------------------------------------

warn "Wikidata lookup"
WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

def wikidata_sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, params: { query: query, format: 'json' }
  json = JSON.parse(result, symbolize_names: true)
  json[:results][:bindings].map { |res| res[:item][:value].split('/').last }
rescue RestClient::Exception => e
  abort "Wikidata query #{query.inspect} failed: #{e.message}"
end

# Position = Member of Argentine Chamber of Deputies
# ids = EveryPolitician::Wikidata.wdq('claim[39:18229570]')
ids = wikidata_sparql('SELECT ?item WHERE { ?item wdt:P39 wd:Q18229570 . }')

warn "  Fetching #{ids.count} items"
people = Wikisnakker::Item.find(ids)
recent = people.select do |mp|
  mp.P39s.find do |posn|
    # https://github.com/everypolitician/wikisnakker/issues/23
    start_date = posn.qualifiers.P580.value rescue nil
    start_date && start_date[0...4].to_i >= 2013
  end
end
warn "    = #{recent.count} recent"

EveryPolitician::Wikidata.scrape_wikidata(ids: recent.map(&:id), batch_size: 100)

warn "DONE!"
