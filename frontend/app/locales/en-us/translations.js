export default {
  "values": {
    "null" : "n/a"
  },
  "stations-list": {
    "label" : "Monitored Sites"
  },
  "indicators": {
    "generic-title": "More Information",

    "imeca": {
      "measurement-datetime-format" : "HH:MM"
    },

    "air-quality": {
      "category-label": "The air quality is",
      "good": {
        "title" : "Good",
        "description" : "No health risk."
      },
      "regular": {
        "title": "Regular",
        "description" : "Adults and children with lung problems, and adults with heart problems, who experience symptoms, should consider reducing strenuous physical activity, particularly outdoors."
      },
      "bad": {
        "title": "Bad",
        "description" : "Adults and children with lung problems, and adults with heart problems, who experience symptoms, should reduce strenuous physical exertion, particularly outdoors, and particularly if they experience symptoms.\n\nPeople with asthma may find they need to use their relievermore often. Older people should also reduce physical exertion."
      },
      "very_bad": {
        "title": "Very Bad",
        "description" : "Adults and children with lung problems, and adults with heart problems, and older people should avoid strenuous physical activity.\n\nPeople with asthma may find they need to use their reliever more often."
      },
      "extremely_bad": {
        "title": "Extremely Bad",
        "description" : "Adults and children with lung problems, and adults with heart problems, and older people should avoid strenuous physical activity. People with asthma may find they need to use their reliever more often."
      }
    },

    "recommended-activities": {
      "label": "Recommended Activities",
      "outdoors" : { "description": "You may perform any outdoor activities." },
      "limited-outdoors" : { "description": "Limit outdoor activities." },
      "no-outdoors" : { "description": "Avoid outdoor activities." },
      "exercise" : { "description": "You may exercise outdoors." },
      "limited-exercise" : { "description": "Limit your outdoor exercise time." },
      "no-exercise": { "description" : "Avoid outdoor exercise." },
      "sensible" : { "description": "No risk for sensible groups." },
      "limited-sensible" : { "description": "Extremely sensible people should limit outdoor activities." },
      "no-sensible" : { "description": "Sensible people should remain indoors." },
      "limit-car" : { "description": "Limit vehicle use." },
      "no-car" : { "description": "Do not use vehicles, unless it is absolutely necessary." },
      "limit-smoking" : { "description": "Limit tobacco smoking." },
      "no-smoking" : { "description": "Do not smoke tobacco products." },
      "window" : { "description": "Keep doors and windows closed." },
      "limited-heart" : { "description": "See your doctor if you present respiratory or cardiovascular problems." },
      "no-fuel" : { "description": "Avoid bonfires and fuel use." }
    },

    "wind": {
      "label" : "Wind Km/h"
    },

    "temperature": {
      "label" : "Temperature ºC"
    },

    "pollutants": {
      "label": "Last hour concentration",
      "toracic-particles": {
        "title": "PM 10 (expressed in μg/m³)",
        "description": "Suspended solid or liquid particles in the air with aerodynamic diameter of 10μm or less. They are emitted from a variety of stationary and mobile sources such as diesel engines, wood stoves, power plants, etc.\n\nConstant exposure to high levels of PM10 has been related to heart and lung diseases, eye, nose and throat irritation, coughing and shortness of breath, reduced lung function, and asthma and heart attacks."
      },
      "respirable-particles": {
        "title": "PM 2.5 (expressed in μg/m³)",
        "description": "Suspended fine particles in the air with aerodynamic diameter of 2.5μm or less. PM2.5 primary sources include road transport, industrial, commercial and domestic burn of fuel, and dust emissions from construction sites.\n\nLong-term exposure to high levels of PM2.5 can cause respiratory and cardiovascular illness, and even death."
      },
      "ozone": {
        "title": "O₃ (expressed in ppb)",
        "description": "Secondary pollutant created by photochemical reactions between nitrogen oxides and volatile organic compounds. Major sources of precursors are industrial and electrical facilities, automovile exhaust, petrol vapours, and chemical solvents.\n\nExposure to O₃ can irritate and swell the lungs, and also irritate the eyes, nose and throat, which can lead to coughing and chest discomfort. Swelling and narrowing of the airways can lead to increased sensitivity to cold air and exercise."
      }
    },

    "forecasts": {
      "label" : "Forecasts",
      "description" : "Maximum expected value."
    }
  }
  // "some.translation.key": "Text for some.translation.key",
  //
  // "a": {
  //   "nested": {
  //     "key": "Text for a.nested.key"
  //   }
  // },
  //
  // "key.with.interpolation": "Text with {{anInterpolation}}"
};
