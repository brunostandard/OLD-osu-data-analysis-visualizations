"""
	This script creates a new .csv file with all the ranked data from the site osu.ppy.sh
	via webscraping. Module scraping_test is a local python script. It's pre-configured to
	go through the 200 pages of html.
	Advice: This script should be used occasionally. It was intended to be used occasionally. 
	My sessions last around 50 seconds before I get warning "too many requests". 
	Around 5 seconds for 10 pages
"""
import bank
import web_scrape_v2
import csv

# create/open a csv file. 
f = open('test2.csv', 'a')

# prepare for writing
w = csv.writer(f)

# example of expected data entries (sourced from the site osu.ppy.sh):
#row = ['bloo', '12372', '98.80', '126410', '93', '705', '614']


string_bank = bank.mega_bank_with_old_format
for my_url in string_bank: 
	my_date = my_url[28:32] + "-" + my_url[32:34] + "-" + my_url[34:36]
	# extract the data from url
	temp_data = web_scrape_v2.scrape_v2(my_url)
	print("successful scrape")
	if len(temp_data) == 0:
		continue
	# entering data into the csv file
	for row in temp_data:
		row.append(my_date)
		w.writerow(row)


# close that file now
f.close()

