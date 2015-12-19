defmodule Soapex.SoapFaultError do
  defexception [:message, :detail]

  def exception(message: message, detail: detail) do
    %__MODULE__{message: message, detail: detail}
  end
end
