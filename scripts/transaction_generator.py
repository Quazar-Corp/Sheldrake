import random
import requests
import netifaces

nfl_teams = [
    "Arizona Cardinals", "Atlanta Falcons", "Baltimore Ravens", "Buffalo Bills",
    "Carolina Panthers", "Chicago Bears", "Cincinnati Bengals", "Cleveland Browns",
    "Dallas Cowboys", "Denver Broncos", "Detroit Lions", "Green Bay Packers",
    "Houston Texans", "Indianapolis Colts", "Jacksonville Jaguars", "Kansas City Chiefs",
    "Las Vegas Raiders", "Los Angeles Chargers", "Los Angeles Rams", "Miami Dolphins",
    "Minnesota Vikings", "New England Patriots", "New Orleans Saints", "New York Giants",
    "New York Jets", "Philadelphia Eagles", "Pittsburgh Steelers", "San Francisco 49ers",
    "Seattle Seahawks", "Tampa Bay Buccaneers", "Tennessee Titans", "Washington Football Team"
]

nba_teams = [
    "Atlanta Hawks", "Boston Celtics", "Brooklyn Nets", "Charlotte Hornets",
    "Chicago Bulls", "Cleveland Cavaliers", "Dallas Mavericks", "Denver Nuggets",
    "Detroit Pistons", "Golden State Warriors", "Houston Rockets", "Indiana Pacers",
    "Los Angeles Clippers", "Los Angeles Lakers", "Memphis Grizzlies", "Miami Heat",
    "Milwaukee Bucks", "Minnesota Timberwolves", "New Orleans Pelicans", "New York Knicks",
    "Oklahoma City Thunder", "Orlando Magic", "Philadelphia 76ers", "Phoenix Suns",
    "Portland Trail Blazers", "Sacramento Kings", "San Antonio Spurs", "Toronto Raptors",
    "Utah Jazz", "Washington Wizards"
]

premier_league_teams = [
    "Arsenal", "Aston Villa", "Brentford", "Brighton & Hove Albion",
    "Burnley", "Chelsea", "Crystal Palace", "Everton",
    "Leeds United", "Leicester City", "Liverpool", "Manchester City",
    "Manchester United", "Newcastle United", "Norwich City", "Southampton",
    "Tottenham Hotspur", "Watford", "West Ham United", "Wolverhampton Wanderers"
]

brasileirao_teams = [
    "América Mineiro", "Athletico Paranaense", "Vasco da Gama", "Atlético Mineiro",
    "Bahia", "Ceará", "Chapecoense", "Corinthians",
    "Cuiabá", "Flamengo", "Fluminense", "Fortaleza",
    "Grêmio", "Internacional", "Juventude", "Palmeiras",
    "Red Bull Bragantino", "Santos", "São Paulo", "Sport"
]

la_liga_teams = [
    "Alavés", "Athletic Bilbao", "Atlético Madrid", "Barcelona",
    "Cádiz", "Celta Vigo", "Eibar", "Elche",
    "Getafe", "Granada", "Levante", "Mallorca",
    "Osasuna", "Rayo Vallecano", "Real Betis", "Real Madrid",
    "Real Sociedad", "Sevilla", "Valencia", "Villarreal"
]

leagues = [nfl_teams, nba_teams, premier_league_teams, brasileirao_teams, la_liga_teams]

# Randomly select a league
selected_league = random.choice(leagues)

# Randomly select sender, receiver, and amount
sender = random.choice(selected_league)
receiver = random.choice(selected_league)
while receiver == sender:
    receiver = random.choice(selected_league)
amount = random.randint(1, 100)

# Function to retrieve the public IP address using the 'netifaces' library
def get_public_ip():
    interfaces = netifaces.interfaces()
    for interface in interfaces:
        ifaddrs = netifaces.ifaddresses(interface)
        if netifaces.AF_INET in ifaddrs:
            addresses = ifaddrs[netifaces.AF_INET]
            for addr in addresses:
                ip_address = addr.get("addr")
                if ip_address and not ip_address.startswith("127."):
                    return ip_address
    return None

# Get the public IP address
ip = get_public_ip()

print(ip)
# Set the endpoint URL
url = f"http://{ip}:8333/blockchain/mock_transaction"

# Set the headers
headers = {
    "client": ip
}

# Set the payload data
payload = {
    "sender": sender,
    "recipient": receiver,
    "amount": amount
}

# Send the POST request
response = requests.post(url, headers=headers, json=payload)

# Check the response status code
if response.status_code == 201:
    print("Transaction successful!")
else:
    print("Transaction failed:", response.text)
