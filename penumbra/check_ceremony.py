import requests
from bs4 import BeautifulSoup

url = "https://summoning.penumbra.zone/phase/1"

# Send a GET request to the URL
response = requests.get(url)

my_wallets = ["penumbra18y3edcxx2t5lnd7c0h8uulsdt7p2frh89nywky229umhreecu5gxtmwmk42xaxqg5dxydwxhc7752humnavvjntt2xwxhre2gzr00mqsjemmaseverds0l09hv5e5jwkdw4u02",
"penumbra12m3m9xk3hmnzf8n0fe8wsg23keunvn23kkev93thapkp8d3y3st9m8scxhz9wz5ynk6vg7ljwxua0t2v4t4nh74k5sy6udljafkndpk9qfuezm8e5lxg66vsnke9687j44r6zr",
"penumbra1mm3ykzpr40ef46nfpaj9x3ns7hp56rvg86yxtz2g8nlxwgswtqwm58y989v87xreaj3anv02xg283d2w67x0hwnuw3u76vx3qd3lanx5uta0esd7hhz5ljy5552zyl28eu083a",
"penumbra1vz0ueze8uwrcsavr4mn8ydzxdcuxdr0mzlgqkcu0lz2376hs5tn5kqfq4day23jdgqgcwm5zanw5qqhwwd3p426uasr0hc5c88xrdaf7lp5cxmqym9dgfplxdek5xn0xut6mzd",
"penumbra1wchlqr7q6avcemftlee3n4juhpypyt9t0ffcyduxk0g48762h64am8ux5xyqe2c8umx2q5f0eqf35nphqy0jgf20ak2mevpnyfstg8srtzudz42grzkr9zpdtpvlk990qccqfz",
"penumbra1xpxth25dsk95nhv2ht70hw05pvz2t5mfprnxt4h8wtaxqewrt87aa5wneqke33pgq2jr9775q4ael32chr6qunn8jhrncg393fthfvw8xymx32asty6y9hpdy7vwsvlp0nlw4l",
"penumbra1hs4ch6p9d4er6rcu8tyedsfp9k80a3u2qq6u0unemdpx2lrczdm4seu2a9pc42anwyslumj6jvq23ptc9yst5r0d363v7lhdgy8pza8zdftgh89368ylvzsd2pdrars5aydhnz",
"penumbra1334jw9ac4ssnux8frefdwwhqq7j3jqqu679aq43c499yn2j2xamxkulhx0qz4gpgq77j2vt8tjh4fw5he56tm2hpul6a857dvrq6chk5kjaqhlge3gprdghv3en2t9gkvezfjj",
"penumbra1j52z9rhxfr5n58wg80q8qd8t8xwv3ekr6npf7ldtl2v7rjs5fvge4pwdf7xgh3xsskpcg589mhzfa5pdtrp0fz7hk9c2qt9ske3vfex5qq6n0y0ej5xuxtqhwhdcja0zxz2cs5",
"penumbra16uadmfl5rfkkj5xgj0rrpftgxcu8zkmv4taq6rchw6tgwyvmnjnk35yp3rmwvc0knv3p789x7np6arkkjntm0jfhgavjr9tmdr584hyjlp9dnvsstztzgn9tarvprqg0n0vwgm",
"penumbra1caynft82daf4046r50k4888yvp8m77yjvtef6cymfp08xlju46jry0pwr5a97ur4hpzhut5jsmzslsl5cpeq6ujm7g47u402aws8qagaggrsl22rxzhexvzt6k64fxhpt2lex7"]

short_my_wallets = [wallet[:30] for wallet in my_wallets]

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all the rows in the table
    rows = soup.find_all('tr', class_='font-mono text-xs')

    # Extract values from the "Who" column
    wallets = [row.contents[3].contents[0] for row in rows]


else:
    print(f"Error: Unable to fetch data. Status code: {response.status_code}")

for my_wallet in short_my_wallets:
    for outside_wallet in wallets:
        if my_wallet in outside_wallet:
            print(f"Wallet done - {my_wallet}")
