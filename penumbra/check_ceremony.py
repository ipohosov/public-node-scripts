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
"penumbra1caynft82daf4046r50k4888yvp8m77yjvtef6cymfp08xlju46jry0pwr5a97ur4hpzhut5jsmzslsl5cpeq6ujm7g47u402aws8qagaggrsl22rxzhexvzt6k64fxhpt2lex7",
              "penumbra1rpjk5dh8t5ltm53ttst276wtgumqfzqy4dzgmdex06ahhx5wzpgaksaxms39dmg3wheypeaek8zu70scrktp8g8u0l4skl9ny2x636zrm7raay6dm2ygsf2m6unuwurvcd7esh",
              "penumbra1wvyrp35pv9swtp3cm8r96j9dlgj4ht0rf5xhurglymqw0g9ctdfu2m9l80kjvyemdnc6p0sr8xpesudeu5vm3rvrd94stef8aawvay3w2e2v4su79etgkq7rx20z4p9jcfgym4",
              "penumbra1htttj9fcgmpn5l8tj6l98jev4wp453dja78zd9fj9v6hq4fu5xxaxdjh3cx23y9ps2cthf6ml0zsuaye4kfp7myzucrry5kwvt4n3zm9w2v7m6dedkynr2fny5gtkm8d85pq7g",
              "penumbra1w0p4pw4yrpmys4zjvqtujvnt6rzv72flcjntqew5fguhvnwszg8ru3kxkknawz7sgmffpdh03a4fe2fpf6tnuq84srhynunzf4n8pprtw650v5u5sc54s45jth0aga065am72j",
              "penumbra1efzyvdm4jspk3z738e07w6mnw096l2k6xgjgxxm78t6mud3hz49redy40n5se4qas7xnq8glfp2t6japnepfmr08ura04tjl7zjzaqe8s47hchcqhwmejmq3w9tfnuysfq7gpv",
              "penumbra1sea32n8ed8juhyn4x6k4x99lr8dysqjteswkrark37n0z5x3md94qyvpnc2ccp2tk2mp9rmer7chm786nr656h7uxqgqa6v5anjfdp97vqyyjkcm744zt07t2d30xjtpxz5n8w",
              "penumbra1wz6ccpk5svfc4l9edtq7v32mz78y6htes6xzms4y06tks0rnrftj985adxuvmwm4cjcyktkmxygtwe5zaagjhfy8wt6l8gelsjmc7vpqkduq6hve9x2dtckfp93z0ukv4r62mv",
              "penumbra1samsfpwg8clvskph9m9r3kqnmt7z3fu8h6h4w99y87043r3fhw0xnug827w2mxuw9u58hsl54vz0ps4km7xypvqnktgs6jzrlkgwczvffd73ccs2dtmlzkf70z5ll7ke2dpmn2",
              "penumbra1ggfpdy5m3h44p8qxlk7fl2s38dszgkqtd22jjp0xhjn0afaddh40r8xslt0lumqnzn29mt3ftt6av4sts8ju7ujeh5e78qczmd4tmltu02ygpsfyp8cst8uw0nqc9ha5yae7z6",
              "penumbra18xgurwaul0dv5pwcyjm4vf9dzfxs8l5umz8juplhrctyz6hmp7mqjcxyl5tz6ym8jvr04n2m0pv4jk6ueuz4ha5m569uywrc8my053vjd0ue2xarl0rkdsl7pmp6gwe92q7rxt",
              "penumbra132ljdpt0f7f3d9ut6g3sthaw7ullvdp22q3jz4j0e54shur4f7z6uphz7v2jsv4f5gk2mqnv7u96kl3dw0s6p9438ra3a035jwyyg6sw088lhyzdd6cudy22n07xx28w8tcmfu"
              ]

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
