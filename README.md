# Zuyd DI-lab - Digital Twin Configurator

Project in naam van - https://dataintelligence.zuyd.nl/

## Digital Twin configurator

### Functies:

* Toevoegen van ´Componenten´ op een raster. Gebruikers kunnen zelf invulling bepalen voor deze componenten. Bijv. het voorstellen van een machine of proces in de maakindustrie.
* Het toewijzen van een naam en pictogram aan een component. Pictogrammen worden voor nu geregeld in `digital-twin-configurator-godot-files/icons` en het script `digital-twin-configurator-godot-files/scripts/Component.gd`.
* Het trainen van datasets voor een component met vier mogelijke modellen. Getrainde datasets worden in een directory opgeslagen (`digitaltwins/api/datasets`).
  * Het inladen van .csv datasets in de Api `local/uploadDataset`. Vervolgens kunnen deze datasets toegewezen worden aan een component.
  * Het kiezen van Features uit een geuploade dataset.
  * Het kiezen van een model (Decision Trees, Random Forests, Neural Networks, Multiple Linear Regression).
* Het inzien van de `R2`, `MSE`, `RMSE` en een scatterplot van een getraind model.


### Dependencies:

* Godot versie 4.2 [https://godotengine.org/]
Python dependencies zijn terug te vinden in de `requirements.txt`.

### Bekende problemen:

* Het inladen van scatterplots in de API in Godot is reeds nog niet geimplementeerd.
* Voor demonstartiedoeleinden, zijn in het `FeatureSelMenu.gd` script de te trainen features hardcored, deze feature-variabele dient te worden toegewezen opgehaald met een `httprequest` node.  

### Installatie & eerste gebruik:

1. Installeer Godot en open `godot.project` in `digital-twin-configurator-godot-files/`.
2. Stappen met betrekking tot de API zijn te vinden in `digitaltwins/readme.md`.

### Gebruik:

1. Godot project openen.
2. API starten met `runcommand.bat`.
3. Lokale webserver gebruiken voor uploaden, inzien data, etc.
4. Godot gebruiken voor trainen model. De menus en componenten in Godot zijn intuitief met knoppen weergegeven.
