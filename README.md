# SOAPex

Erlsom/Detergent wrapper to call and provide SOAP interfaces for Elixir/Phoenix.

Some basic methods to read, transform and map Erlsom records and models.
Also a Plug and Phoenix controller template using the mappings.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add soapex to your list of dependencies in `mix.exs`:

        def deps do
          [{:soapex, "~> 0.1.0"}]
        end

  2. Ensure soapex is started before your application:

        def application do
          [applications: [:soapex]]
        end

