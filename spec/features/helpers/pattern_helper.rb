module PatternHelper
  def pattern_spec
    visit_patterns

    create_first_pattern
    edit_patterns
    delete_patterns
    create_second_pattern
  end

  def create_first_pattern
    pattern_params = {
      match_text: 'My Match Text',
      notes: 'New Note',
      category: 'Category One',
      subcategory: 'Subcategory One'
    }
    create_pattern(pattern_params)
    verify_pattern(pattern_params)
  end

  def create_second_pattern
    pattern_params = {
      match_text: 'supermarket',
      notes: 'myPatternNote',
      category: 'Category Two',
      subcategory: 'Subcategory Two'
    }
    create_pattern(pattern_params)
    verify_pattern(pattern_params)
  end

  def edit_patterns
    edited_pattern_params = {
      match_text: 'Edited Text',
      notes: 'Edited Note',
      category: 'Category Two',
      subcategory: 'Subcategory Two'
    }
    edit_pattern('My Match Text', edited_pattern_params)
    verify_pattern(edited_pattern_params)
  end

  def delete_patterns
    delete_pattern('Edited Text')
    verify_pattern_deleted('Edited Text')
  end

  def visit_patterns
    visit '/react#/patterns'
    wait_for_finished_loading

    expect(page).to have_text('my patterns')
  end

  def create_pattern(pattern_params)
    click_on 'New'

    fill_in_pattern_form(pattern_params)

    click_on 'Save'
    wait_for_finished_loading
  end

  def edit_pattern(text, pattern_params)
    click_on_row_with_text text

    fill_in_pattern_form(pattern_params)

    click_on 'Save'
    wait_for_finished_loading
  end

  def delete_pattern(text)
    click_on_row_with_text text
    click_on 'Delete'
    click_on 'Yes, Delete'
    wait_for_finished_loading
  end

  def fill_in_pattern_form(pattern_params)
    fill_in 'matchText', with: pattern_params[:match_text] if pattern_params[:match_text]
    fill_in 'notes', with: pattern_params[:notes] if pattern_params[:notes]
    select_dropdown_option('categoryId', pattern_params[:category]) if pattern_params[:category]
    select_dropdown_option('subcategoryId', pattern_params[:subcategory]) if pattern_params[:subcategory]
  end

  def verify_pattern(pattern_params)
    within 'tr', text: pattern_params[:match_text] do
      expect(page).to have_text(pattern_params[:notes])
      expect(page).to have_text(pattern_params[:category])
      expect(page).to have_text(pattern_params[:subcategory])
    end
  end

  def verify_pattern_deleted(match_text)
    expect(page).not_to have_text(match_text)
  end
end
