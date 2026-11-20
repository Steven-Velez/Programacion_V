const body = document.querySelector("#table-body");
const state = { page: 1, pageSize: 10, query: "", sortKey: "name", direction: 1 };
const currency = new Intl.NumberFormat("en-US", {
  style: "currency", currency: "USD", maximumFractionDigits: 0
});
//const tableInfo = document.querySelector("#")

const CITIES_ENDPOINT = "/api/v1/ciudades";
let pageSize = 10;//Number(pageSizeSelect.value);
let currentPage = 1;
let sortKey = "ciudad";
let sortOrder = "asc";
let currentCities = [];

function normalize(value) {
  return String(value).normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}


async function loadCities(page = currentPage) {
  try {
    const query = new URLSearchParams({
      page: String(page),
      limit: String(pageSize),
      sort: sortKey,
      order: sortOrder,
    });
    const response = await fetch(`${CITIES_ENDPOINT}?${query}`);
    const payload = await response.json();

    render(payload.data);

  } catch (error) {
    console.error("Error al cargar las ciudades:", error);
  }

}

function render(filtered = "") {
  body.replaceChildren();
  currentCities = filtered; console.log(currentCities)

  filtered.forEach(city => {
    const row = document.createElement("tr");
    [city.id, city.ciudad, city.pais, ""].forEach(value => {
      const cell = document.createElement("td");
      cell.textContent = value;
      row.append(cell);
    });

    const actionsCell = document.createElement("td");
    actionsCell.className = "row-actions";
    actionsCell.append(
      createActionButton("Modificar", "edit", city.id, "edit-button"),
      createActionButton("Borrar", "delete", city.id, "delete-button"),
    );
    row.append(actionsCell);

    body.append(row);
  });
}
function createActionButton(label, action, cityId, className) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = `action-button ${className}`;
  button.dataset.action = action;
  button.dataset.cityId = cityId;
  button.textContent = label;
  button.setAttribute("aria-label", `${label} ciudad ${cityId}`);
  return button;
}
const addCityButton = document.querySelector("#add-city-button");

const cityForm = document.querySelector("#city-form");
function listenAddCityButton() {
  addCityButton.addEventListener("click", () => {
    cityForm.open();
  });

  cityForm.addEventListener("city-saved", () => {
    loadCities();
  }); 
}
function listenTableActions() {
  body.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-action]");

    if (!button) {
      return;
    }

    const cityId = Number(button.dataset.cityId);
    const city = currentCities.find((item) => item.id === cityId);

    if (!city) {
      return;
    }

    if (button.dataset.action === "edit") {
      cityForm.open(city);
      return;
    }

    if (button.dataset.action === "delete") {
      deleteCity(city, button);
    }
  });
}
async function deleteCity(city, button) {
  const confirmed = window.confirm(
    `¿Desea borrar la ciudad "${city.ciudad}"?`,
  );

  if (!confirmed) {
    return;
  }

  button.disabled = true;

  try {
    const response = await fetch(`/api/v1/ciudades/${city.id}`, {
      method: "DELETE",
    });

    if (!response.ok) {
      const payload = await response.json();
      throw new Error(payload.error?.message || "No fue posible borrar la ciudad.");
    }

    await loadCities();
  } catch (error) {
    window.alert(error.message);
    button.disabled = false;
  }
}

listenTableActions();
listenAddCityButton();
loadCities();
