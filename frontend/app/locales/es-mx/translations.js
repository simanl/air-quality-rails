export default {
  "values": {
    "null" : "n/d"
  },
  "indicators": {
    "generic-title": "Más Información",

    "air-quality": {
      "category-label": "La calidad del aire es",
      "good": {
        "title" : "Buena",
        "description" : "Ningun riesgo a la salud."
      },
      "regular": {
        "title": "Regular",
        "description": "Posibles molestias en niños, adultos mayores y personas con enfermedades respiratorias o cardiovasculares."
      },
      "bad": {
        "title": "Mala",
        "description": "Posibles efectos adversos a la salud, en particular niños, adultos mayores y personas con enfermedades cardiovasculares o respiratorias."
      },
      "very-bad": {
        "title": "Muy Mala",
        "description": "Efectos adversos a la salud de la población en general. Se agravan los síntomas en niños, adultos mayores y personas con enfermedades cardiovasculares o respiratorias."
      },
      "extremely-bad": {
        "title": "Extremadamente Mala",
        "description": "Efectos graves a la salud de la población en general. Se pueden presentar complicaciones en niños, adultos mayores y personas con enfermedades cardiovasculares o respiratorias."
      }
    },

    "recommended-activities": {
      "label": "Actividades Recomendadas",
      "exercise" : { "description": "Puedes ejercitarte al aire libre." },
      "limited-exercise" : { "description": "Limita el tiempo para ejercitarte al aire libre." },
      "no-exercise": { "description" : "Evita ejercitarte al aire libre." },
      "outdoors" : { "description": "Puedes realizar actividades al aire libre." },
      "limited-outdoors" : { "description": "Limita las actividades al aire libre." },
      "no-outdoors" : { "description": "Evita las actividades al aire libre." },
      "sensible" : { "description": "Sin riesgo para grupos sensibles." },
      "limited-sensible" : { "description": "Personas extremadamente sensibles limitar actividades al aire libre." },
      "no-sensible" : { "description": "Grupos sensibles permanecer en interiores." },
      "limit-car" : { "description": "Limita el uso de vehículos automotores." },
      "no-car" : { "description": "No uses vehículos automotores a menos que sea necesario." },
      "limit-smoking" : { "description": "Si eres fumador, limita el consumo del tabaco." },
      "no-smoking" : { "description": "No fumar." },
      "window" : { "description": "Mantén cerradas puertas y ventanas." },
      "limited-heart" : { "description": "Acude al médico si presentas síntomas de enfermedades respiratorias o cardiovasculares." },
      "no-fuel" : { "description": "Evita hacer fogatas y el uso de combustibles sólidos (carbón y leña)." }
    },

    "wind": {
      "label" : "Viento Km/h"
    },

    "temperature": {
      "label" : "Temperatura ºC"
    },

    "pollutants": {
      "label": "Concentraciones última hora",
      "toracic-particles": {
        "title": "PM 10 (expresado en μg x m³)",
        "description": "Partículas suspendidas líquidas o sólidas con diámetro aerodinámico igual o menor de 10μm. Son emitidas por una variedad de fuentes fijas y móviles, como camiones a diesel, estufas de leña, centrales eléctricas, etc.\n\nLa exposición constante a niveles elevados de PM10 ha sido relacionada con irritación de los ojos, nariz y garganta, tos frecuente y dificultad  para respirar, ataques de asma, al corazón y afectaciones a las funciones pulmonares."
      },
      "respirable-particles": {
        "title": "PM 2.5 (expresado en μg x m³)",
        "description": "Partículas finas suspendidas en el aire con diámetro aerodinámico igual o menor de 2.5μm. Son emitidas durante cualquier proceso de combustión, incluyendo vehículos motorizados, centrales eléctricas, quema de biomasa e incendios forestales, además de algunos procesos industriales.\n\nLa exposición por largos períodos a PM2.5 ha sido asociada con problemas de afecciónes respiratorias y cardiacas, principalmente entre grupos susceptibles como adultos mayores e infantes."
      },
      "ozone": {
        "title": "O₃ (expresado en ppb)",
        "description": "Contaminante secundario formado durante reacciones fotoquímicas entre óxidos de nitrógeno y compuestos orgánicos volátiles. Emisiones de instalaciones eléctricas e industriales, vehiculares, vapores de gasolina y sovlentes son algunas de las mayores fuentes de precursores.\n\nLa exposición a O₃ puede desencadenar en afecciones del sistema respiratorio tales como asma, especialmente en niños y adultos mayores."
      }
    },

    "forecasts": {
      "label" : "Pronóstico"
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
