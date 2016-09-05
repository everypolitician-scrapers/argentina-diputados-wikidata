#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://es.wikipedia.org/wiki/Elecciones_legislativas_de_Argentina_de_2013',
  after: '//span[@id="Diputados_elegidos"]',
  xpath: './/table[1]//tr//td[1]//a[not(@class="new")]/@title',
)

# Position = Member of Argentine Chamber of Deputies
WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

def wikidata_sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, params: { query: query, format: 'json' }
  json = JSON.parse(result, symbolize_names: true)
  json[:results][:bindings].map { |res| res[:item][:value].split('/').last }
rescue RestClient::Exception => e
  abort "Wikidata query #{query.inspect} failed: #{e.message}"
end

# ids = EveryPolitician::Wikidata.wdq('claim[39:18229570]')
ids = wikidata_sparql('SELECT ?item WHERE { ?item wdt:P39 wd:Q18229570 . }')

people = Wikisnakker::Item.find(ids)
recent = people.select do |mp|
  mp.P39s.find do |posn|
    # https://github.com/everypolitician/wikisnakker/issues/23
    start_date = posn.qualifiers.P580.value rescue nil
    start_date && start_date[0...4].to_i >= 2013
  end
end

EveryPolitician::Wikidata.scrape_wikidata(ids: recent.map(&:id), names: { es: names }, batch_size: 250)
