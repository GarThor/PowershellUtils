[CmdletBinding()]
param (
    [string]${Name}    = "Dave"
)

[string[]]$affirmations = @(
    "${Name} can do this.",
    "${Name} has everything ${Name} needs  right here, right now.",
    "If ${Name} believes ${Name} can then ${Name} will.",
    "${Name}'s past experiences do not define ${Name}'s future.",
    "${Name} will embrace the challenges of today and let them guide ${Name}'s next steps.",
    "Just because something hasn’t gone right before, it doesn’t mean it won’t ever go right.",
    "${Name} is capable and ${Name} is strong.",
    "${Name} is beautiful.",
    "${Name} will not let negative thoughts and energies bring ${Name} down.",
    "${Name} will learn from past mistakes and use them to encourage better decisions for the future.",
    "The future may be uncertain but that won’t stop ${Name} looking forward with hope.",
    "${Name} will look after ${Name}'s body and mind and treat them kindly and with respect.",
    "${Name} is brave, resilient and strong.",
    "${Name} can manage change and will adapt to what those changes bring.",
    "${Name} has  the power to change what ${Name} needs to.",
    "${Name} will allow ${Name}'s self grace when things don’t go to plan.",
    "${Name} accept that ${Name} can’t change things that are beyond ${Name}'s control.",
    "${Name} is doing the best that ${Name} can and that is enough.",
    "${Name} loves ${Name}'s self and looks after ${Name}'s self without feeling guilty or selfish.",
    "People appreciate ${Name} for who ${Name} is and not who I’d like to be.",
    "${Name} will stop chasing things that ${Name} don’t have and appreciate all that ${Name} has  right now.",
    "${Name} has  the potential to achieve whatever ${Name} want.",
    "${Name}'s goals and ambitions will come true and ${Name} has  a plan in place to make sure ${Name} achieve them.",
    "If ${Name} want something badly enough, ${Name} can find a way to make it happen.",
    "${Name} is unique and ${Name} has  many gifts that ${Name} can use to help ${Name}'s self and others.",
    "Success and happiness in ${Name}'s life is largely up to ${Name}.",
    "${Name} will stop holding ${Name}'s self back or hiding from opportunities.",
    "Life is wonderful and ${Name} live every day to the full.",
    "${Name} forgive those who have hurt ${Name} in the past.",
    "${Name} will seize every opportunity that comes ${Name}'s way.",
    "${Name} is grateful for ${Name}'s life and the people, experiences and things in it.",
    "${Name} is grateful for ${Name}'s family, friends and loved ones.",
    "${Name}'s body does amazing things and ${Name} looks after it every day.",
    "Times may be tough but they won’t stay that way. Nothing is permanent.",
    "If ${Name} needs help, ${Name} knows it’s ok to ask for it and seek out support.",
    "${Name} takes ownership of ${Name}'s life and the direction it takes.",
    "${Name} will show up for ${Name}'s life.",
    "${Name} may be fearful of the future or the unknown, but ${Name} can conquer that fear and it won’t hold ${Name} back.",
    "${Name} works hard to nurture positive daily habits and say no to unhealthy habits.",
    "${Name} will focus on improving ${Name}'s life instead of being envious of others.",
    "${Name} see problems not as obstacles but as opportunities for learning and growth.",
    "${Name} choose action over inaction, decision over procrastination.",
    "${Name} is excited and hopeful for what ${Name}'s future could hold.",
    "${Name} is a good role model for ${Name}'s children and loved ones.",
    "${Name} is respected and trusted and ${Name}'s opinion is valid.",
    "${Name} is a valued good friend and confidante for those who need love, kindness and support.",
    "${Name} is loved.",
    "${Name} uses ${Name}'s talents and skills to contribute in a meaningful and positive way.",
    "${Name} understand that life can be difficult but ${Name} has a positive mindset to help ${Name} ride stormy seas.",
    "${Name} is flexible and adaptable to change and always embrace new things.",
    "${Name} is ready to learn and know that personal growth is a life-long exercise.",
    "${Name} commit to expanding ${Name}'s horizons and stepping out of ${Name}'s comfort zone every now and then.",
    "${Name} listens to ${Name}'s body, mind and heart and nourish them however serves them best.",
    "${Name} lean into ${Name}'s emotions and understand how to manage them in a positive, healthy way.",
    "${Name} will stop judging others by ${Name}'s own standards and focus instead on managing ${Name}'s own expectations.",
    "${Name} will not try to control situations and experiences that are beyond ${Name}'s control but instead focus ${Name}'s energies on the things in ${Name}'s own life which ${Name} can control.",
    "${Name} is worthy of financial success and happiness, whatever that looks like to ${Name}.",
    "${Name} trust ${Name}'s own judgement and that the decisions ${Name} make are the right ones for ${Name}.",
    "${Name} knows ${Name}'s priorities and assess them regularly to ensure they align with what ${Name} really wants from life.",
    "${Name} is happy, content and at peace with who ${Name} is right now."
)

[int]$randIdx = Get-Random -Maximum $affirmations.Count
[string]$myAffirmation = $affirmations[$randIdx]

$colors = [Enum]::GetValues([System.ConsoleColor]) | Where-Object {$_ -notin @("Black")}
[int]$randColorIdx = Get-Random -Maximum $colors.Count
$color = [Enum]::GetValues([System.ConsoleColor])[$randColorIdx]

Write-Host $myAffirmation -ForegroundColor $color 