defmodule AuthorizeWeb.Buzz.TopicLiveTest do
  use AuthorizeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Authorize.Buzz.TopicsFixtures

  alias Authorize.Core.Accounts
  alias Authorize.Admin.Authorized

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_topic(_) do
    topic = topic_fixture()
    %{topic: topic}
  end

  defp create_admin(_) do
    user_attrs = %{
      email: "admin@example.com",
      password: "A-L0ng-pa55word-4-U"
    }
    {:ok, user} = Accounts.register_user(user_attrs)
    Authorized.grant_admin(user)
    # reload with admin role
    admin = Accounts.get_user_by_email("admin@example.com")
    %{admin: admin}
  end

  defp create_user(_) do
    user_attrs = %{
      email: "user@example.com",
      password: "A-L0ng-pa55word-4-U"
    }
    {:ok, user} = Accounts.register_user(user_attrs)
    %{user: user}
  end

  describe "non-authenticated access attempt" do
    setup [:create_topic]

    test "redirects to login page", %{conn: conn} do
      expected_flash = %{"error" => "You must log in to access this page."}
      {:error, redirect} = live(conn, ~p"/admin/topics")
      assert redirect == {:redirect, %{to: "/access/users/log_in", flash: expected_flash}}
    end
  end

  describe "non-authorized access attempt" do
    setup [:create_topic, :create_user]

    test "redirects to login page", %{conn: conn, user: user} do
      conn = put_session(conn, :user_id, user.id)
      # IO.inspect(conn, label: "with seesion")
      conn = assign(conn, :current_user, user)
      # IO.inspect(conn, label: "after connection")

      {:error, redirect} = live(conn, ~p"/admin/topics")
      expected_flash = %{"error" => "You must be an admin to access this page."}
      assert redirect == {:redirect, %{to: "/access/users/log_in", flash: expected_flash}}
    end
  end

  describe "Authorized Index" do
    setup [:create_topic, :create_admin]

    test "lists all topics", %{conn: conn, topic: topic, admin: admin} do
      conn = fetch_session(conn)
      conn = put_session(conn, :user_id, admin.id)
      conn = assign(conn, :current_user, admin)
      # IO.inspect(conn, label: "after connection")
      {:ok, _index_live, html} = live(conn, ~p"/admin/topics")

      assert html =~ "Listing Topics"
      assert html =~ topic.title
    end

    test "saves new topic", %{conn: conn, admin: admin} do
      conn = assign(conn, :current_user, admin)
      {:ok, index_live, _html} = live(conn, ~p"/admin/topics")

      assert index_live |> element("a", "New Topic") |> render_click() =~
               "New Topic"

      assert_patch(index_live, ~p"/admin/topics/new")

      assert index_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#topic-form", topic: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/topics")

      html = render(index_live)
      assert html =~ "Topic created successfully"
      assert html =~ "some title"
    end

    test "updates topic in listing", %{conn: conn, topic: topic, admin: admin} do
      conn = assign(conn, :current_user, admin)
      {:ok, index_live, _html} = live(conn, ~p"/admin/topics")

      assert index_live |> element("#topics-#{topic.id} a", "Edit") |> render_click() =~
               "Edit Topic"

      assert_patch(index_live, ~p"/admin/topics/#{topic}/edit")

      assert index_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#topic-form", topic: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/topics")

      html = render(index_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes topic in listing", %{conn: conn, topic: topic, admin: admin} do
      conn = assign(conn, :current_user, admin)
      {:ok, index_live, _html} = live(conn, ~p"/admin/topics")

      assert index_live |> element("#topics-#{topic.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#topics-#{topic.id}")
    end
  end

  describe "Authorized Show" do
    setup [:create_topic, :create_admin]

    test "displays topic", %{conn: conn, topic: topic, admin: admin} do
      conn = assign(conn, :current_user, admin)
      {:ok, _show_live, html} = live(conn, ~p"/admin/topics/#{topic}")

      assert html =~ "Show Topic"
      assert html =~ topic.title
    end

    test "updates topic within modal", %{conn: conn, topic: topic, admin: admin} do
      conn = assign(conn, :current_user, admin)
      {:ok, show_live, _html} = live(conn, ~p"/admin/topics/#{topic}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Topic"

      assert_patch(show_live, ~p"/admin/topics/#{topic}/show/edit")

      assert show_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#topic-form", topic: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/topics/#{topic}")

      html = render(show_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated title"
    end
  end
end
