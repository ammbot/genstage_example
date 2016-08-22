defmodule Ku.Mixfile do
  use Mix.Project

  def project do
    [app: :ku,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Ku, []}]
  end

  defp deps do
    [{:gen_stage, "~> 0.5"}]
  end
end
