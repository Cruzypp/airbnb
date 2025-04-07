
defmodule Airbnb do

  NimbleCSV.define(CSVParser, separator: ",", escape: "\"")


  def aggr_count_properties(path \\ "ejemplo.csv") do
    # Lee y parsea el archivo CSV a una lista de registros
    registros =
      File.stream!(path)
      |> CSVParser.parse_stream()
      |> Enum.to_list()

    # Separa los encabezados y el contenido
    _encabezados = hd(registros)
    contenido = tl(registros)

    # Extrae las columnas de zonas y tipos de propiedad
    zonas = Enum.map(contenido, &Enum.at(&1, 28))
    tipos = Enum.map(contenido, &Enum.at(&1, 32))

    # Combina zonas y tipos en pares
    pares_zona_tipo = Enum.zip(zonas, tipos)

    # Cuenta la frecuencia de cada combinación única de zona y tipo
    conteo = Enum.frequencies(pares_zona_tipo)

    # Formatea y muestra los resultados
    conteo
    |> Enum.map(fn {{colonia, tipo_propiedad}, total} ->
      "(Colonia: #{colonia}, Tipo: #{tipo_propiedad}, Total: #{total})\n"
    end)
    |> Enum.join("  ")
    |> IO.puts()
  end


  def offer_by_neighbourhood(path \\ "listings_sample_500.csv") do
    registros =
      File.stream!(path)
      |> CSVParser.parse_stream()
      |> Enum.to_list()

    # Elimina la fila de encabezados
    contenido = tl(registros)

    # Extrae las columnas necesarias:
    # - Colonias (28)
    # - Capacidad de hospedaje (34)
    # - Precios (40)
    colonias = Enum.map(contenido, &Enum.at(&1, 28))
    capacidad_raw = Enum.map(contenido, &Enum.at(&1, 34))
    precios_raw = Enum.map(contenido, &Enum.at(&1, 40))

    # Convierte las capacidades de string a números enteros
    capacidades =
      Enum.map(capacidad_raw, fn valor ->
        case Integer.parse(valor) do
          {numero, _} -> numero
          :error -> 0
        end
      end)

    # Elimina símbolos de $ y comas
    precios =
      Enum.map(precios_raw, fn precio ->
        limpio = String.replace(precio, "$", "") |> String.replace(",", "")
        case Float.parse(limpio) do
          {numero, _} -> round(numero)
          :error -> 0
        end
      end)

    # Combina los datos de colonias, capacidades y precios
    datos_combinados = Enum.zip([colonias, capacidades, precios])

    # Acumula totales por colonia:
    # - Suma de capacidades
    # - Suma de precios
    acumulados_por_colonia =
      Enum.reduce(datos_combinados, %{}, fn {colonia, capacidad, precio}, acumulador ->
        Map.update(acumulador, colonia, {capacidad, precio}, fn {cap_total, prec_total} ->
          {cap_total + capacidad, prec_total + precio}
        end)
      end)

    # Calcula y formatea los resultados finales
    salida =
      acumulados_por_colonia
      |> Enum.map(fn {colonia, {total_capacidad, total_precio}} ->
        # Calcula el precio promedio por persona, evitando división por cero
        promedio =
          if total_capacidad > 0 do
            Float.round(total_precio / total_capacidad, 2)
          else
            0
          end

        # Formatea la salida para cada colonia
        "(Colonia: #{colonia}, Total hospedajes: #{total_capacidad}, Precio promedio por persona: $#{promedio})\n"
      end)
      |> Enum.join(" ")

    # Muestra los resultados
    IO.puts(salida)
  end
end
