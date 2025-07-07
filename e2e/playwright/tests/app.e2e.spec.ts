import { test, expect } from '@playwright/test';

test('La page liste les employés', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByText('Liste des employés')).toBeVisible();
});
