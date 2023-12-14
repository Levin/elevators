defmodule House do
  use GenServer

  def add_elevator(house, e_nr, max_floor) do
    GenServer.cast(build_housename(house), {:new_elevator, {e_nr, max_floor}})
  end

  def info(house) do
    GenServer.call(build_housename(house), :info)
  end

  def start_link(housename) do
    GenServer.start_link(__MODULE__, %{elevators: []}, name: build_housename(housename))
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:new_elevator, {e_nr, floor}}, state) do
    {:ok, pid} =  Elevator.start_link(e_nr, floor)
    new_elevator = %{elevator_number: e_nr, pid: pid}
    new_state = %{state | elevators: [new_elevator | state.elevators]}
    {:noreply, new_state}
  end

  def terminate(reason, state) do
    IO.inspect("terminate/2 callback")
    IO.inspect({:reason, reason})
    IO.inspect({:state, state})
  end

  defp build_housename(name) do
    name
    |> String.to_atom()
  end

end
