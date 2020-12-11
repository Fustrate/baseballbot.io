I18n.translations || (I18n.translations = {});
I18n.translations["de"] = I18n.extend((I18n.translations["de"] || {}), {"errors":{"messages":{"content_type_invalid":"hat einen ungültigen Dateityp","dimension_height_equal_to":"Bildhöhe muss genau %{length} Pixel sein","dimension_height_greater_than_or_equal_to":"Bildhöhe muss größer oder gleich %{length} Pixel sein","dimension_height_inclusion":"Bildhöhe muss zwischen %{min} und %{max} Pixel liegen","dimension_height_less_than_or_equal_to":"Höhe muss kleiner oder gleich %{length} Pixel sein","dimension_max_inclusion":"muss kleiner oder gleich %{width} x %{height} Pixel sein","dimension_min_inclusion":"muss größer oder gleich %{width} x %{height} Pixel sein","dimension_width_equal_to":"Bildbreite muss genau %{length} Pixel sein","dimension_width_greater_than_or_equal_to":"Bildbreite muss größer oder gleich %{length} Pixel sein","dimension_width_inclusion":"Bildbreite muss zwischen %{min} und %{max} Pixel liegen","dimension_width_less_than_or_equal_to":"Breite muss kleiner oder gleich %{length} Pixel sein","file_size_out_of_range":"Dateigröße %{file_size} liegt nicht im erlaubten Bereich","image_metadata_missing":"ist kein gültiges Bild","limit_out_of_range":"Anzahl ist außerhalb des gültigen Bereichs"}}});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {"activerecord":{"errors":{"messages":{"record_invalid":"Validation failed: %{errors}","restrict_dependent_destroy":{"has_many":"Cannot delete record because dependent %{record} exist","has_one":"Cannot delete record because a dependent %{record} exists"}}}},"date":{"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"},"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"],"order":["year","month","day"]},"datetime":{"distance_in_words":{"about_x_hours":{"one":"about 1 hour","other":"about %{count} hours"},"about_x_months":{"one":"about 1 month","other":"about %{count} months"},"about_x_years":{"one":"about 1 year","other":"about %{count} years"},"almost_x_years":{"one":"almost 1 year","other":"almost %{count} years"},"half_a_minute":"half a minute","less_than_x_minutes":{"one":"less than a minute","other":"less than %{count} minutes"},"less_than_x_seconds":{"one":"less than 1 second","other":"less than %{count} seconds"},"over_x_years":{"one":"over 1 year","other":"over %{count} years"},"x_days":{"one":"1 day","other":"%{count} days"},"x_minutes":{"one":"1 minute","other":"%{count} minutes"},"x_months":{"one":"1 month","other":"%{count} months"},"x_seconds":{"one":"1 second","other":"%{count} seconds"}},"prompts":{"day":"Day","hour":"Hour","minute":"Minute","month":"Month","second":"Seconds","year":"Year"}},"errors":{"connection_refused":"Oops! Failed to connect to the Web Console middleware.\nPlease make sure a rails development server is running.\n","format":"%{attribute} %{message}","messages":{"accepted":"must be accepted","aspect_ratio_is_not":"must have an aspect ratio of %{aspect_ratio}","aspect_ratio_not_landscape":"must be a landscape image","aspect_ratio_not_portrait":"must be a portrait image","aspect_ratio_not_square":"must be a square image","aspect_ratio_unknown":"has an unknown aspect ratio","blank":"can't be blank","confirmation":"doesn't match %{attribute}","content_type_invalid":"has an invalid content type","dimension_height_equal_to":"height must be equal to %{length} pixel","dimension_height_greater_than_or_equal_to":"height must be greater than or equal to %{length} pixel","dimension_height_inclusion":"height is not included between %{min} and %{max} pixel","dimension_height_less_than_or_equal_to":"height must be less than or equal to %{length} pixel","dimension_max_inclusion":"must be less than or equal to %{width} x %{height} pixel","dimension_min_inclusion":"must be greater than or equal to %{width} x %{height} pixel","dimension_width_equal_to":"width must be equal to %{length} pixel","dimension_width_greater_than_or_equal_to":"width must be greater than or equal to %{length} pixel","dimension_width_inclusion":"width is not included between %{min} and %{max} pixel","dimension_width_less_than_or_equal_to":"width must be less than or equal to %{length} pixel","empty":"can't be empty","equal_to":"must be equal to %{count}","even":"must be even","exclusion":"is reserved","file_size_out_of_range":"size %{file_size} is not between required range","greater_than":"must be greater than %{count}","greater_than_or_equal_to":"must be greater than or equal to %{count}","image_metadata_missing":"is not a valid image","inclusion":"is not included in the list","invalid":"is invalid","less_than":"must be less than %{count}","less_than_or_equal_to":"must be less than or equal to %{count}","limit_out_of_range":"total number is out of range","model_invalid":"Validation failed: %{errors}","not_a_number":"is not a number","not_an_integer":"must be an integer","odd":"must be odd","other_than":"must be other than %{count}","present":"must be blank","required":"must exist","taken":"has already been taken","too_long":{"one":"is too long (maximum is 1 character)","other":"is too long (maximum is %{count} characters)"},"too_short":{"one":"is too short (minimum is 1 character)","other":"is too short (minimum is %{count} characters)"},"wrong_length":{"one":"is the wrong length (should be 1 character)","other":"is the wrong length (should be %{count} characters)"}},"unacceptable_request":"A supported version is expected in the Accept header.\n","unavailable_session":"Session %{id} is no longer available in memory.\n\nIf you happen to run on a multi-process server (like Unicorn or Puma) the process\nthis request hit doesn't store %{id} in memory. Consider turning the number of\nprocesses/workers to one (1) or using a different server in development.\n"},"hello":"Hello world","helpers":{"select":{"prompt":"Please select"},"submit":{"create":"Create %{model}","submit":"Save %{model}","update":"Update %{model}"}},"number":{"currency":{"format":{"delimiter":",","format":"%u%n","precision":2,"separator":".","significant":false,"strip_insignificant_zeros":false,"unit":"$"}},"format":{"delimiter":",","precision":3,"separator":".","significant":false,"strip_insignificant_zeros":false},"human":{"decimal_units":{"format":"%n %u","units":{"billion":"Billion","million":"Million","quadrillion":"Quadrillion","thousand":"Thousand","trillion":"Trillion","unit":""}},"format":{"delimiter":"","precision":3,"significant":true,"strip_insignificant_zeros":true},"storage_units":{"format":"%n %u","units":{"byte":{"one":"Byte","other":"Bytes"},"eb":"EB","gb":"GB","kb":"KB","mb":"MB","pb":"PB","tb":"TB"}}},"nth":{"ordinalized":{},"ordinals":{}},"percentage":{"format":{"delimiter":"","format":"%n%"}},"precision":{"format":{"delimiter":""}}},"support":{"array":{"last_word_connector":", and ","two_words_connector":" and ","words_connector":", "}},"time":{"am":"am","formats":{"default":"%a, %d %b %Y %H:%M:%S %z","long":"%B %d, %Y %H:%M","short":"%d %b %H:%M"},"pm":"pm"},"will_paginate":{"container_aria_label":"Pagination","next_label":"Next \u0026#8594;","page_aria_label":"Page %{page}","page_entries_info":{"multi_page":"Displaying %{model} %{from} - %{to} of %{count} in total","multi_page_html":"Displaying %{model} \u003cb\u003e%{from}\u0026nbsp;-\u0026nbsp;%{to}\u003c/b\u003e of \u003cb\u003e%{count}\u003c/b\u003e in total","single_page":{"one":"Displaying 1 %{model}","other":"Displaying all %{count} %{model}","zero":"No %{model} found"},"single_page_html":{"one":"Displaying \u003cb\u003e1\u003c/b\u003e %{model}","other":"Displaying \u003cb\u003eall\u0026nbsp;%{count}\u003c/b\u003e %{model}","zero":"No %{model} found"}},"page_gap":"\u0026hellip;","previous_label":"\u0026#8592; Previous"}});
I18n.translations["fr"] = I18n.extend((I18n.translations["fr"] || {}), {"errors":{"messages":{"aspect_ratio_is_not":"doit avoir un rapport hauteur / largeur de %{aspect_ratio}","aspect_ratio_not_landscape":"doit être une image en format paysage","aspect_ratio_not_portrait":"doit être une image en format portrait","aspect_ratio_not_square":"doit être une image en format carrée","aspect_ratio_unknown":"a un rapport d'aspect inconnu","content_type_invalid":"a un type de contenu non valide","dimension_height_equal_to":"la hauteur doit être égale à %{length} pixels","dimension_height_greater_than_or_equal_to":"la hauteur doit être supérieure ou égale à %{length} pixels","dimension_height_inclusion":"la hauteur n'est pas comprise entre %{min} et %{max} pixels","dimension_height_less_than_or_equal_to":"la hauteur doit être inférieure ou égale à %{length} pixels","dimension_max_inclusion":"doit être inférieur ou égal à %{width} x %{height} pixels","dimension_min_inclusion":"doit être supérieur ou égal à %{width} x %{height} pixels","dimension_width_equal_to":"la largeur doit être égale à %{length} pixels","dimension_width_greater_than_or_equal_to":"la largeur doit être supérieure ou égale à %{length} pixels","dimension_width_inclusion":"la largeur n'est pas comprise entre %{min} et %{max} pixels","dimension_width_less_than_or_equal_to":"la largeur doit être inférieure ou égale à %{length} pixels","file_size_out_of_range":"la taille %{file_size} n'est pas comprise dans la plage permise","image_metadata_missing":"n'est pas une image valide","limit_out_of_range":"le nombre total est hors limites"}}});
I18n.translations["ja"] = I18n.extend((I18n.translations["ja"] || {}), {"errors":{"messages":{"aspect_ratio_is_not":"のアスペクト比は %{aspect_ratio} にしてください","aspect_ratio_not_landscape":"は横長にしてください","aspect_ratio_not_portrait":"は縦長にしてください","aspect_ratio_not_square":"は正方形にしてください","aspect_ratio_unknown":"のアスペクト比を取得できませんでした","content_type_invalid":"のContent Typeが不正です","dimension_height_equal_to":"の縦幅は %{length} ピクセルにしてください","dimension_height_greater_than_or_equal_to":"の縦幅は %{length} ピクセル以上にしてください","dimension_height_inclusion":"の縦幅は %{min} ピクセル以上 %{max} ピクセル以下にしてください","dimension_height_less_than_or_equal_to":"の縦幅は %{length} ピクセル以下にしてください","dimension_max_inclusion":"は %{width} x %{height} ピクセル以下の大きさにしてください","dimension_min_inclusion":"は %{width} x %{height} ピクセル以上の大きさにしてください","dimension_width_equal_to":"の横幅は %{length} ピクセルにしてください","dimension_width_greater_than_or_equal_to":"の横幅は %{length} ピクセル以上にしてください","dimension_width_inclusion":"の横幅は %{min} ピクセル以上 %{max} ピクセル以下にしてください","dimension_width_less_than_or_equal_to":"の横幅は %{length} ピクセル以下にしてください","file_size_out_of_range":"の容量 %{file_size} が許容範囲外です","image_metadata_missing":"は不正な画像です","limit_out_of_range":"の数が許容範囲外です"}}});
I18n.translations["pt-BR"] = I18n.extend((I18n.translations["pt-BR"] || {}), {"errors":{"messages":{"aspect_ratio_is_not":"não contém uma proporção de %{aspect_ratio}","aspect_ratio_not_landscape":"não contém uma imagem no formato paisagem","aspect_ratio_not_portrait":"não contém uma imagem no formato retrato","aspect_ratio_not_square":"não é uma imagem quadrada","aspect_ratio_unknown":"não tem uma proporção definida","content_type_invalid":"tem um tipo de arquivo inválido","dimension_height_equal_to":"altura deve ser igual a %{length} pixel","dimension_height_greater_than_or_equal_to":"altura deve ser maior ou igual a %{length} pixel","dimension_height_inclusion":"altura não está entre %{min} e %{max} pixel","dimension_height_less_than_or_equal_to":"altura deve ser menor ou igual a %{length} pixel","dimension_max_inclusion":"deve ser menor ou igual a %{width} x %{height} pixel","dimension_min_inclusion":"deve ser maior ou igual a %{width} x %{height} pixel","dimension_width_equal_to":"largura deve ser igual a %{length} pixel","dimension_width_greater_than_or_equal_to":"largura deve ser maior ou igual a %{length} pixel","dimension_width_inclusion":"largura não está entre %{min} e %{max} pixel","dimension_width_less_than_or_equal_to":"largura deve ser menor ou igual a %{length} pixel","file_size_out_of_range":"tamanho %{file_size} está fora da faixa de tamanho válida","image_metadata_missing":"não é uma imagem válida","limit_out_of_range":"número total está fora do limite"}}});
I18n.translations["ru"] = I18n.extend((I18n.translations["ru"] || {}), {"errors":{"messages":{"aspect_ratio_is_not":"должен иметь соотношение сторон %{aspect_ratio}","aspect_ratio_not_landscape":"должно быть пейзажное изображение","aspect_ratio_not_portrait":"должно быть портретное изображение","aspect_ratio_not_square":"должно быть квадратное изображение","aspect_ratio_unknown":"имеет неизвестное соотношение сторон","content_type_invalid":"имеет недопустимый тип содержимого","dimension_height_equal_to":"высота должна быть равна %{length} пикселям","dimension_height_greater_than_or_equal_to":"высота должна быть больше или равна %{length} пикселям","dimension_height_inclusion":"высота не включена между %{min} и %{max}  пикселям","dimension_height_less_than_or_equal_to":"высота должна быть меньше или равна %{length} пикселям","dimension_max_inclusion":"должно быть меньше или равно %{width} x %{height} пикселям","dimension_min_inclusion":"должен быть больше или равно %{width} x %{height} пикселям","dimension_width_equal_to":"ширина должна быть равна %{length} пикселям","dimension_width_greater_than_or_equal_to":"ширина должна быть больше или равна %{length} пикселям","dimension_width_inclusion":"ширина не включена между %{min} и %{max} пикселям","dimension_width_less_than_or_equal_to":"ширина должна быть меньше или равна %{length} пикселям","file_size_out_of_range":"размер %{file_size} больше требуемого","image_metadata_missing":"не является допустимым изображением","limit_out_of_range":"количество файлов больше требуемого"}}});
I18n.translations["tr"] = I18n.extend((I18n.translations["tr"] || {}), {"errors":{"messages":{"aspect_ratio_is_not":"%{aspect_ratio} en boy oranına sahip olmalı","aspect_ratio_not_landscape":"yatay bir imaj olmalı","aspect_ratio_not_portrait":"dikey bir imaj olmalı","aspect_ratio_not_square":"kare bir imaj olmalı","aspect_ratio_unknown":"bilinmeyen en boy oranı","content_type_invalid":"geçersiz dosya tipine sahip","dimension_height_equal_to":"boy %{length} piksele eşit olmalı","dimension_height_greater_than_or_equal_to":"boy %{length} piksele eşit ya da büyük olmalı","dimension_height_inclusion":"boy %{min} ve %{max} piksel aralığı dışında","dimension_height_less_than_or_equal_to":"boy %{length} piksele eşit ya da küçük olmalı","dimension_max_inclusion":"%{width} x %{height} piksele eşit ya da küçük olmalı","dimension_min_inclusion":"%{width} x %{height} piksele eşit ya da büyük olmalı","dimension_width_equal_to":"en %{length} piksele eşit olmalı","dimension_width_greater_than_or_equal_to":"en %{length} piksele eşit ya da büyük olmalı","dimension_width_inclusion":"en %{min} ve %{max} piksel aralığı dışında","dimension_width_less_than_or_equal_to":"en %{length} piksele eşit ya da küçük olmalı","file_size_out_of_range":"dosya boyutu %{file_size} gerekli aralık dışında","image_metadata_missing":"geçerli bir imaj değil","limit_out_of_range":"toplam miktar aralık dışında"}}});
I18n.translations["uk"] = I18n.extend((I18n.translations["uk"] || {}), {"errors":{"aspect_ratio_is_not":"мусить мати співвідношення сторін %{aspect_ratio}","aspect_ratio_not_landscape":"мусить бути пейзажне зображення","aspect_ratio_not_portrait":"мусить бути портретне зображення","aspect_ratio_not_square":"мусить бути квадратне зображення","aspect_ratio_unknown":"має невідоме співвідношення сторін","content_type_invalid":"має неприпустимий тип вмісту","dimension_height_equal_to":"висота мусить дорівнювати %{length} пікселям","dimension_height_greater_than_or_equal_to":"висота мусить бути більше або дорівнювати %{length} пікселям","dimension_height_inclusion":"висота не включена між %{min} і %{max} пікселям","dimension_height_less_than_or_equal_to":"висота мусить бути менше або дорівнювати %{length} пікселям","dimension_max_inclusion":"мусить бути менше або дорівнювати %{width} x %{height} пікселям","dimension_min_inclusion":"мусить бути більше або дорівнювати %{width} x %{height} пікселям","dimension_width_equal_to":"ширина мусить дорівнювати %{length} пікселям","dimension_width_greater_than_or_equal_to":"ширина мусить бути більше або дорівнювати %{length} пікселям","dimension_width_inclusion":"ширина не включена між %{min} і %{max} пікселям","dimension_width_less_than_or_equal_to":"ширина мусить бути менше або дорівнювати %{length} пікселям","file_size_out_of_range":"розмір %{file_size} більше необхідного","image_metadata_missing":"не є допустимим зображенням","limit_out_of_range":"кількість файлів більше необхідного","messages":null}});