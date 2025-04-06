defmodule Airbnb do
  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  def aggr_count_properties(path \\ "ejemplo.csv") do
    datos =
      File.stream!(path)
      |> MyParser.parse_stream()
      |> Enum.to_list()

    filas = tl(datos)

    neighbourhood =
      Enum.map(filas, fn fila -> Enum.at(fila, 28) end)

    property_type =
      Enum.map(filas, fn fila -> Enum.at(fila, 32) end)

    combinados =
      Enum.zip(neighbourhood, property_type)
      |> Enum.map(fn {zona, tipo} -> "(Colonia:#{zona} - Tipo:#{tipo})" end)

    lista_f = Enum.join(combinados, ", ")

    IO.inspect(lista_f)
  end
end
