#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'
require 'pry'

names = EveryPolitician::Wikidata.wikipedia_xpath( 
  url: 'https://es.wikipedia.org/wiki/Elecciones_legislativas_de_Argentina_de_2013',
  after: '//span[@id="Diputados_elegidos"]',
  xpath: './/table[1]//tr//td[1]//a[not(@class="new")]/@title',
) 

EveryPolitician::Wikidata.scrape_wikidata(names: { es: names }, output: true)
warn EveryPolitician::Wikidata.notify_rebuilder

