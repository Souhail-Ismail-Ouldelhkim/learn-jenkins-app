// @ts-check
const { test, expect } = require("@playwright/test");

test("has title", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle(/Learn Jenkins/);
});

test("has Jenkins in the body", async ({ page }) => {
  await page.goto("/");
  const isVisible = await page
    .locator('a:has-text("Learn Jenkins on Udemy")')
    .isVisible();
  expect(isVisible).toBeTruthy();
});

test("has expected app version", async ({ page }) => {
  await page.goto("/");

  const expectedAppVersion = process.env.REACT_APP_VERSION
    ? process.env.REACT_APP_VERSION
    : "1";

  console.log("Test cherche version:", expectedAppVersion);

  // ✅ textContent() récupère tout le texte du <p>
  const pageText = await page.locator("p").textContent();
  console.log("Page contient:", pageText);

  expect(pageText).toContain(`Application version: ${expectedAppVersion}`);
});
