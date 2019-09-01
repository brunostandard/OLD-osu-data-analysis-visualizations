"""
	This is an auxillary module for the scraper script in the local directory. The purpose
	of this module is to scrape through the internet and gather data. In particular, it scrapes
	from osu.ppy.sh ranked webpages. After getting the HTML page, some parsing and formatting is
	done too. The code is not intended to used often, so the code is not optimized. 
"""
# we are going to read html text
import bs4 # parse html text
# We need a web-client.
from urllib.request import urlopen as uReq # grabbing the page itself
from urllib.request import Request
from bs4 import BeautifulSoup as soup

def scrape(my_url):
	""" Just scrape, parse, and return a list of lists (dataset)"""
	final_data = [] # we'll add information to this and return at the end
	req = Request(my_url, headers={'User-Agent': 'Mozilla/5.0'})
	uClient = uReq(req) # opens a connection, and dowload. (it's a client)
	#dumping contents
	page_html = uClient.read() #The web_byte is a byte object returned by the server and the content type present in webpage is mostly utf-8.
	page_html = page_html.decode('utf-8')
	uClient.close()

	# The following is earlier version of using the urlopen client. It didn't work out 	
	"""
	my_url = "https://osu.ppy.sh/rankings/osu/performance?page=**#scores"
	my_url = my_url.replace("**",str(page_number))
	uClient = uReq(my_url) # opens a connection, and dowload. (it's a client)
	page_html = uClient.read() # dumps everything (will be unable to read it if not stored)
	uClient.close()
	"""

	#html parser
	page_soup = soup(page_html,"html.parser") # parsing as html (could have been xml)

	"""
	# need to make a loop for every row
	# body ranking-page ranking-page-table tbody 
	#ranking-page-table__row

	#grab every tr with class "..." in page. 
	containers = page_soup.findAll("tr",{"class":"ranking-page-table__row"})

	len(containers) # == 50 (yse!!!)

	container = containers[0] # should just be html
	a_containers = container.findAll("a", {"class" : "ranking-page-table__user-link-text js-usercard"}) # to get the thing holding the name
	# There's actually only one item, and we need to filter out the space
	name = a_containers[0].text.replace("\n","").strip()

	# to get data for player, we go through all the td's holding the information. For some reason, the stat
	# for performance is being held in a td with a different class name. Hence, we'll need two td containers
	td_containers_1 = container.findAll("td",{"class":"ranking-page-table__column ranking-page-table__column--dimmed"})
	td_containers_2 = container.findAll("td",{"class":"ranking-page-table__column ranking-page-table__column--focused"})

	# There's actually only one element on td_containers_2, and that element is a performance stat. 
	performance = td_containers_2[0].text.replace("\n","").strip().replace(",","")

	# other player stats from td_container_1.
	stats = [container.text.replace("\n","").strip().replace(",","").replace("%","") for container in td_containers_1]

	final_row = [name,performance]
	final_row.extend(stats)

	# now that it's been tested above. We can do dis recursively
	"""
	containers = page_soup.findAll("tr",{"class":"ranking-page-table__row"})
	for container in containers:
		#sometimes it will need to be changed to span depending on how recent the url is. 
		a_containers = container.findAll("a",{"class" : "ranking-page-table__user-link-text js-usercard"})		# There's actually only one item, and we need to filter out the space
		name = a_containers[0].text.replace("\n","").strip()

		# to get data for player, we go through all the td's holding the information. For some reason, the stat
		# for performance is being held in a td with a different class name. Hence, we'll need two td containers
		td_containers_1 = container.findAll("td",{"class":"ranking-page-table__column ranking-page-table__column--dimmed"})
		td_containers_2 = container.findAll("td",{"class":"ranking-page-table__column ranking-page-table__column--focused"})

		# There's actually only one element on td_containers_2, and that element is a performance stat. 
		performance = td_containers_2[0].text.replace("\n","").strip().replace(",","")

		# other player stats from td_container_1.
		stats = [container.text.replace("\n","").strip().replace(",","").replace("%","") for container in td_containers_1]

		final_row = [name,performance]
		final_row.extend(stats)
		final_data.append(final_row)
	return final_data
