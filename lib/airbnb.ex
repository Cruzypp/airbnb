defmodule Airbnb do
  NimbleCSV.define(CSVParser, separator: ",", escape: "\"")

  def aggr_count_properties(path \\ "ejemplo.csv") do
    registros =
      File.stream!(path)
      |> CSVParser.parse_stream()
      |> Enum.to_list()

    _encabezados = hd(registros)
    contenido = tl(registros)

    zonas = Enum.map(contenido, &Enum.at(&1, 28))
    tipos = Enum.map(contenido, &Enum.at(&1, 32))

    pares_zona_tipo = Enum.zip(zonas, tipos)

    conteo = Enum.frequencies(pares_zona_tipo)

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

    contenido = tl(registros)

    colonias = Enum.map(contenido, &Enum.at(&1, 28))
    capacidad_raw = Enum.map(contenido, &Enum.at(&1, 34))
    precios_raw = Enum.map(contenido, &Enum.at(&1, 40))

    capacidades =
      Enum.map(capacidad_raw, fn valor ->
        case Integer.parse(valor) do
          {numero, _} -> numero
          :error -> 0
        end
      end)

    precios =
      Enum.map(precios_raw, fn precio ->
        limpio = String.replace(precio, "$", "") |> String.replace(",", "")
        case Float.parse(limpio) do
          {numero, _} -> round(numero)
          :error -> 0
        end
      end)

    datos_combinados = Enum.zip([colonias, capacidades, precios])

    acumulados_por_colonia =
      Enum.reduce(datos_combinados, %{}, fn {colonia, capacidad, precio}, acumulador ->
        Map.update(acumulador, colonia, {capacidad, precio}, fn {cap_total, prec_total} ->
          {cap_total + capacidad, prec_total + precio}
        end)
      end)

    salida =
      acumulados_por_colonia
      |> Enum.map(fn {colonia, {total_capacidad, total_precio}} ->
        promedio =
          if total_capacidad > 0 do
            Float.round(total_precio / total_capacidad, 2)
          else
            0
          end

        "(Colonia: #{colonia}, Total hospedaje: #{total_capacidad}, Precio promedio por persona: $#{promedio})\n"
      end)
      |> Enum.join(" ")

    IO.puts(salida)
  end

end
