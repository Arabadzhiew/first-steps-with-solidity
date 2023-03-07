pragma solidity 0.4.24;

contract PlanetEarth {
    enum Continent {
        EUROPE,
        ASIA,
        AFRICA,
        AUSTRALIA,
        NORTH_AMERICA,
        SOUTH_AMERICA,
        ANTARCTICA
    }

    struct Country {
        string name;
        Continent continent;
        uint256 population;
    }

    mapping(string => string) private countryCapitals;
    mapping(string => bool) private specifiedCapitals;

    Country[] public europeanCountries;

    event EuropeanCountryAdded(string name, uint256 population);
    event CapitalAdded(string countryName, string capitalName);
    event CapitalRemoved(string countryName, string capitalName);

    function addEuropeanCountry(string _name, uint256 _population) public {
        europeanCountries.push(Country(_name, Continent.EUROPE ,_population));

        emit EuropeanCountryAdded(_name, _population);
    }

    function addCapitalForCountry(string _countryName, string _capitalName) public {
        require(!specifiedCapitals[_capitalName], "A country has already been linked to this capital!");

        countryCapitals[_countryName] = _capitalName;
        specifiedCapitals[_capitalName] = true;

        emit CapitalAdded(_countryName, _capitalName);
    }

    function getCapital(string _countryName) public view returns(string) {
        return countryCapitals[_countryName];
    }

    function removeCapital(string _countryName) public {
        string memory removedCapitalName = countryCapitals[_countryName];

        delete countryCapitals[_countryName];
        specifiedCapitals[_countryName] = false;

        emit CapitalRemoved(_countryName, removedCapitalName);
    }

    function getContinentName(Continent _continent) public pure returns(string) {
        if(_continent == Continent.EUROPE) {
            return "Europe";
        }else if (_continent == Continent.ASIA) {
            return "Asia";
        }else if (_continent == Continent.AFRICA) {
            return "Africa";
        }else if (_continent == Continent.AUSTRALIA) {
            return "Australia";
        }else if (_continent == Continent.NORTH_AMERICA) {
            return "North America";
        }else if (_continent == Continent.SOUTH_AMERICA) {
            return "South America";
        }else if (_continent == Continent.ANTARCTICA) {
            return "Antarctica";
        }
    }
}