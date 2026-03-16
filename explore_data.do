/*******************************************************************************
*PROJECT: EVOKE data
*PURPOSE: Explore
*******************************************************************************/
clear all
set more off 
pause on 
global main "~/Documents/GitHub/EVOKE"

* Export data to upload to claude for categorization
import delimited using "$main/Korean_English_mappings/Emotion_Words_Combined_Clean.csv", clear
keep if korean_word != ""
sort korean_word english_word note
keep korean_word 
duplicates drop
export delimited using "$main/llm_categories/korean_words.csv", replace

import delimited using "$main/Korean_English_mappings/Emotion_Words_Combined_Clean.csv", clear
keep if english_word != ""
sort english_word
keep english_word 
duplicates drop
export delimited using "$main/llm_categories/english_words.csv", replace


* Import claude mappings and generate analysis data 
import delimited using "$main/llm_categories/korean_words_classified.csv", clear varnames(1)
rename category cat3_korean
tempfile cat3_korean
save `cat3_korean'

import delimited using "$main/llm_categories/korean_words_cat13.csv", clear varnames(1)
rename category cat13_korean
tempfile cat13_korean
save `cat13_korean'

import delimited using "$main/llm_categories/english_words_classified.csv", clear varnames(1)
rename category cat3_english
tempfile cat3_english
save `cat3_english'

import delimited using "$main/llm_categories/english_words_cat13.csv", clear varnames(1)
rename category cat13_english
tempfile cat13_english
save `cat13_english'


* Merge classifications on to mapping
import delimited using "$main/Korean_English_mappings/Emotion_Words_Combined_Clean.csv", clear
merge m:1 korean_word using `cat3_korean', nogen
merge m:1 english_word using `cat3_english', nogen
merge m:1 korean_word using `cat13_korean', nogen
merge m:1 english_word using `cat13_english', nogen

compress
save "$main/llm_categories/analysis.dta", replace
export delimited using "$main/llm_categories/analysis.csv", replace

* Combine data for analysis
use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if korean_word != ""
*duplicates drop korean_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat13_korean)
rename cat13_korean cat_str
gen lang_korean = 1
tempfile korean_words 
save `korean_words'

use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if english_word != ""
*duplicates drop english_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat13_english)
rename cat13_english cat_str
gen lang_korean = 0

append using `korean_words'
encode cat_str, gen(cat_num)

reshape wide word_count word_pct, i(cat_num) j(lang_korean)

* 13 category figures
graph bar word_count1 word_count0, over(cat_num, sort(word_count1) descending label(angle(45) labsize(small))) ///
    ytitle("Count") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Counts by Emotion Category: All Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/all_freq_cat13.png", replace
	
graph bar word_pct1 word_pct0, over(cat_num, sort(word_pct1) descending label(angle(45) labsize(small))) ///
    ytitle("Percent") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Percents by Emotion Category: All Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/all_pct_cat13.png", replace
	
* Non matching words	
use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if english_word == ""
*duplicates drop korean_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat13_korean)
rename cat13_korean cat_str
gen lang_korean = 1
tempfile korean_words 
save `korean_words'

use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if korean_word == ""
*duplicates drop english_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat13_english)
rename cat13_english cat_str
gen lang_korean = 0

append using `korean_words'
encode cat_str, gen(cat_num)

reshape wide word_count word_pct, i(cat_num) j(lang_korean)

graph bar word_count1 word_count0, over(cat_num, sort(word_count1) descending label(angle(45) labsize(small))) ///
    ytitle("Count") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Counts by Emotion Category: Non-Matching Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/non_match_freq_cat13.png", replace
graph bar word_pct1 word_pct0, over(cat_num, sort(word_pct1) descending label(angle(45) labsize(small))) ///
    ytitle("Percent") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Percents by Emotion Category: Non-Matching Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/non_match_pct_cat13.png", replace	

* Combine data for analysis - 3 category 
use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if korean_word != ""
*duplicates drop korean_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat3_korean)
rename cat3_korean cat_str
gen lang_korean = 1
tempfile korean_words 
save `korean_words'

use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if english_word != ""
*duplicates drop english_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat3_english)
rename cat3_english cat_str
gen lang_korean = 0

append using `korean_words'
encode cat_str, gen(cat_num)

reshape wide word_count word_pct, i(cat_num) j(lang_korean)

graph bar word_count1 word_count0, over(cat_num, sort(word_count1) descending label(angle(45) labsize(small))) ///
    ytitle("Count") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Counts by Emotion Category: All Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/all_freq_cat3.png", replace
	
graph bar word_pct1 word_pct0, over(cat_num, sort(word_pct1) descending label(angle(45) labsize(small))) ///
    ytitle("Percent") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Percents by Emotion Category: All Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/all_pct_cat3.png", replace
	
* Non matching words	
use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if english_word == ""
*duplicates drop korean_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat3_korean)
rename cat3_korean cat_str
gen lang_korean = 1
tempfile korean_words 
save `korean_words'

use "$main/llm_categories/analysis.dta", clear
gen word_count = 1
keep if korean_word == ""
*duplicates drop english_word, force
collapse (count) word_count (percent) word_pct = word_count, by(cat3_english)
rename cat3_english cat_str
gen lang_korean = 0

append using `korean_words'
encode cat_str, gen(cat_num)

reshape wide word_count word_pct, i(cat_num) j(lang_korean)

graph bar word_count1 word_count0, over(cat_num, sort(word_count1) descending label(angle(45) labsize(small))) ///
    ytitle("Count") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Counts by Emotion Category: Non-Matching Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/non_match_freq_cat3.png", replace
graph bar word_pct1 word_pct0, over(cat_num, sort(word_pct1) descending label(angle(45) labsize(small))) ///
    ytitle("Percent") legend(order(1 "Korean" 2 "English") pos(2) ring(0)) ///
    title("Word Percents by Emotion Category: Non-Matching Words") ///
    blabel(bar, format(%9.0f) size(small))
graph export "$main/llm_categories/non_match_pct_cat3.png", replace		
			
		