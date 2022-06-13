defmodule TestAppWeb.Live.ComplexButtonComponentTest do
  use TestAppWeb.ConnCase, async: true

  alias TestAppWeb.Live.ComplexButtonComponent

  alias LiveIsolatedComponent.Spy
  alias Phoenix.LiveView, as: LV

  import LiveIsolatedComponent
  import Phoenix.LiveViewTest

  test "sends a @on_click info event" do
    {:ok, view, _html} =
      live_isolated_component(ComplexButtonComponent,
        assigns: %{on_click: :i_was_clicked}
      )

    view |> element("button") |> render_click()

    # we can assert_receive or check the last_info
    LiveIsolatedComponent.assert_receive_info(view, {:i_was_clicked, 1})
    assert {:i_was_clicked, 1} == LiveIsolatedComponent.last_info(view)

    view |> element("button") |> render_click()

    view_pid = view.pid
    assert_receive {:handle_info, view_pid, {:i_was_clicked, 2}}
    assert {:i_was_clicked, 2} == LiveIsolatedComponent.last_info(view)
  end

  test "default impl for spy" do
    handle_info_spy =
      Spy.handle_info(fn {:i_was_clicked, count}, socket ->
        {:noreply, LV.assign(socket, :description, "red-ish #{count}")}
      end)

    {:ok, view, _html} =
      live_isolated_component(ComplexButtonComponent,
        assigns: %{on_click: :i_was_clicked},
        handle_info: handle_info_spy.callback
      )

    view |> element("button") |> render_click()

    assert has_element?(view, "button", "My red-ish 1 button")

    view |> element("button") |> render_click()

    assert has_element?(view, "button", "My red-ish 2 button")
  end

  test "spy result" do
    handle_info_spy = Spy.handle_info()

    {:ok, view, _html} =
      live_isolated_component(ComplexButtonComponent,
        assigns: %{on_click: :i_was_clicked},
        handle_info: handle_info_spy.callback
      )

    view |> element("button") |> render_click()

    assert %{result: {:noreply, _s}} = Spy.last_event(handle_info_spy)
  end
end
