defmodule Elevator do
  use GenServer
  require Logger

  def info(e_nr) do
    GenServer.call(build_name(e_nr), :info)
  end

  def up_floor(e_nr, floors \\ 1) do
    GenServer.call(build_name(e_nr), {:up_floor, floors})
  end

  def down_floor(e_nr, floors \\ 1) do
    GenServer.call(build_name(e_nr), {:down_floor, floors})
  end

  def new_driver(e_nr, n \\ 1) do
    GenServer.cast(build_name(e_nr), {:add_driver, n})
  end

  def remove_driver(e_nr, n \\ 1) do
    GenServer.cast(build_name(e_nr), {:remove_driver, n})
  end

  def move?(e_nr, run?) do
    GenServer.cast(build_name(e_nr), {:move, run?})
  end

  def start_link(e_nr, max_floor) do
    GenServer.start_link(__MODULE__, %{max_floor: max_floor}, name: build_name(e_nr))
  end

  @impl true
  def init(params) do
    # build state 
    state = %{floor: 1, drivers: 0, time_to_top: nil, height: params.max_floor * 2.25 ,move?: false, max_floor: params.max_floor, current_run: 0}

    {:ok, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:up_floor, floors}, _from, state) do
    max_speed = 10
    up_floors = 
      cond do
        floors > 5 -> 
          acc = 3 * (10*0.65)
          break = 2 * (10*0.5)
          normal = (floors - 5) * max_speed
          acc + break + normal
        floors == 1 -> 
          1 * 10
        true -> 
          breaks = div(floors,2)
          accs = floors - breaks

          breaks * (10 * 0.5) + accs * (10 * 0.65)
      end

    new_floor = up_floors + state.floor
    {:reply, new_floor, %{state | floor: new_floor}}
  end

  @impl true
  def handle_call({:down_floor, floors}, _from, state) do
    max_speed = 10
    new_floor = state.floor - floors
    {:reply, new_floor, %{state | floor: new_floor}}
  end

  def handle_cast({:add_driver, amount},  state) do
    new_drivers = state.drivers + amount
    {:noreply, %{state | drivers: new_drivers}}
  end

  def handle_cast({:remove_driver, amount}, state) do
    new_drivers = state.drivers - amount
    {:noreply, %{state | drivers: new_drivers}}
  end

  def handle_cast({:move, value}, state) do
    case value do
      true -> {:noreply, %{state | move?: true}}
      false -> {:noreply, %{state | move?: false}}
    end
  end

 def build_name(number) do
    "elevator_#{number}"
    |> String.to_atom()
  end

end
